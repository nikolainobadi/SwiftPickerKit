//
//  SignalHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation

/// Restores the terminal on SIGINT/SIGTERM, then forwards the signal to the host's saved handler
/// (see `SignalForwarding`); the picker never decides on its own that the process should exit.
///
/// Only one registration can be active per process. The host's handlers are saved on setup and
/// restored on removal, so the picker never permanently replaces them.
enum SignalHandler {
    /// `nonisolated(unsafe)`: guards process-global signal registration, which has no actor.
    /// Access is confined to picker setup/teardown on a single thread.
    nonisolated(unsafe) private static var isHandlerSet = false

    /// Installs SIGINT/SIGTERM handlers, saving the host's handlers for `removeSignalHandlers()`.
    ///
    /// Idempotent, so the saved host handlers are never overwritten with the picker's own.
    ///
    /// - Parameter cleanup: Runs on signal receipt, before the signal is forwarded to the host.
    static func setupSignalHandlers(cleanup: @escaping () -> Void) {
        guard !isHandlerSet else { return }

        globalCleanupHandler = cleanup
        interruptReceived = 0
        isHandlerSet = true

        // SA_SIGINFO so a host handler that also uses it can be chained with the real
        // siginfo and context
        var action = sigaction()
        action.__sigaction_u.__sa_sigaction = signalHandler
        sigemptyset(&action.sa_mask)
        action.sa_flags = SA_SIGINFO

        // Install ours, saving whatever the host had installed
        sigaction(SIGINT, &action, &previousInterruptAction)
        sigaction(SIGTERM, &action, &previousTerminateAction)
    }

    /// Restores the host's saved handlers (`SIG_DFL`, `SIG_IGN`, or custom) rather than the system
    /// default, so the host's own interrupt handling keeps working. No-op if nothing is registered.
    static func removeSignalHandlers() {
        guard isHandlerSet else { return }

        sigaction(SIGINT, &previousInterruptAction, nil)
        sigaction(SIGTERM, &previousTerminateAction, nil)
        globalCleanupHandler = nil
        isHandlerSet = false
    }

    /// Runs cleanup, marks `wasInterrupted`, then forwards the signal per the host's saved action.
    ///
    /// Separate from the C handler so tests can drive it without real signals, which an attached
    /// debugger would intercept.
    ///
    /// - Parameters:
    ///   - signal: The signal number.
    ///   - info: Passed through to a chained `SA_SIGINFO` host handler.
    ///   - context: Passed through to a chained `SA_SIGINFO` host handler.
    static func handle(signal: Int32, info: UnsafeMutablePointer<__siginfo>?, context: UnsafeMutableRawPointer?) {
        globalCleanupHandler?()
        interruptReceived = 1

        var previousAction = signal == SIGINT ? previousInterruptAction : previousTerminateAction

        switch forwarding(for: previousAction) {
        case .reraiseDefault:
            // Process-directed rather than `raise`: thread-directed signals are unsupported on
            // GCD worker threads, where a picker called from async code may be running. The
            // signal stays blocked on this thread until the handler returns, then the default
            // action runs.
            sigaction(signal, &previousAction, nil)
            kill(getpid(), signal)
        case .leaveToHost:
            break
        case .chainToHandler:
            if previousAction.sa_flags & SA_SIGINFO != 0 {
                previousAction.__sigaction_u.__sa_sigaction?(signal, info, context)
            } else {
                previousAction.__sigaction_u.__sa_handler?(signal)
            }
        }
    }

    /// Whether SIGINT or SIGTERM arrived since the last setup. When the host handles the signal
    /// itself the process keeps running, so the input loop checks this to stop drawing and finish.
    static var wasInterrupted: Bool {
        return interruptReceived != 0
    }

    /// Blocks the calling thread for good, leaving the host's interrupt handling to end the process.
    ///
    /// Used by `PickerInterruptBehavior.waitForTermination`. The picker's handlers stay installed,
    /// so a further signal still restores the terminal and reaches the host's handler.
    static func parkUntilTermination() -> Never {
        while true {
            pause()
        }
    }

    /// Decides how a received signal is passed on, based on the host's saved action.
    static func forwarding(for previousAction: sigaction) -> SignalForwarding {
        switch handlerAddress(of: previousAction) {
        case handlerAddress(of: SIG_DFL):
            return .reraiseDefault
        case handlerAddress(of: SIG_IGN):
            return .leaveToHost
        default:
            return .chainToHandler
        }
    }
}

// MARK: - SignalForwarding
/// What the picker's signal handler does after restoring the terminal.
enum SignalForwarding: Equatable {
    /// The host had no handler: reinstall the default action and re-raise, so the process
    /// dies from the signal and reports 130 (SIGINT) or 143 (SIGTERM).
    case reraiseDefault

    /// The host ignores the signal — typically because it observes it through a
    /// `DispatchSource`, which already saw this delivery. Re-raising would look like a
    /// second signal to the host, so nothing more is done.
    case leaveToHost

    /// The host installed its own C handler: call it with the same signal.
    case chainToHandler
}

// MARK: - Private Implementation
/// File scope and `nonisolated(unsafe)` because a C signal handler cannot capture Swift context
/// or carry actor isolation.
nonisolated(unsafe) private var globalCleanupHandler: (() -> Void)?

/// The host's SIGINT and SIGTERM actions, saved by `setupSignalHandlers` and restored by
/// `removeSignalHandlers`. File scope and `nonisolated(unsafe)` for the same reason as
/// `globalCleanupHandler`.
nonisolated(unsafe) private var previousInterruptAction = sigaction()
nonisolated(unsafe) private var previousTerminateAction = sigaction()

/// Set by the signal handler, cleared by `setupSignalHandlers`. `sig_atomic_t` because it is
/// written from signal context; file scope and `nonisolated(unsafe)` like the storage above.
nonisolated(unsafe) private var interruptReceived: sig_atomic_t = 0

/// The installed C handler; delegates to `SignalHandler.handle`.
private func signalHandler(_ signal: Int32, _ info: UnsafeMutablePointer<__siginfo>?, _ context: UnsafeMutableRawPointer?) {
    SignalHandler.handle(signal: signal, info: info, context: context)
}

/// The raw address of an action's handler, comparable against `SIG_DFL` (0) and `SIG_IGN` (1).
private func handlerAddress(of action: sigaction) -> Int {
    return handlerAddress(of: action.__sigaction_u.__sa_handler)
}

private func handlerAddress(of handler: sig_t?) -> Int {
    guard let handler else { return 0 }
    return unsafeBitCast(handler, to: Int.self)
}
