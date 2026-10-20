//
//  SignalHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation

/// Internal utility for handling termination signals to ensure proper terminal cleanup.
///
/// When SwiftPicker uses the alternate screen buffer, it's critical to restore the terminal
/// to its normal state if the user interrupts the program (Ctrl+C) or the process is terminated.
/// Without signal handling, interrupted pickers can leave the terminal in an unusable state.
///
/// ## How It Works
///
/// This handler registers callbacks for SIGINT (Ctrl+C) and SIGTERM (process termination).
/// When these signals are received, it executes the cleanup closure to restore terminal state,
/// then forwards the signal to whatever the host application had installed (see
/// `SignalForwarding`). The picker never decides on its own that the process should exit.
///
/// ## Usage
///
/// SwiftPickerKit uses this automatically in `SelectionHandler`. Users of the library don't
/// need to interact with this type directly.
///
/// ```swift
/// // Internal usage pattern:
/// SignalHandler.setupSignalHandlers {
///     pickerInput.exitAlternativeScreen()
///     pickerInput.enableNormalInput()
/// }
///
/// // ... run picker ...
///
/// SignalHandler.removeSignalHandlers()
/// ```
///
/// ## Implementation Notes
///
/// The handler uses a global variable to store the cleanup closure because C signal handlers
/// cannot capture Swift context. Only one signal handler can be active at a time across the
/// entire process. The host application's own handlers are saved on setup and restored on
/// removal, so the picker never permanently replaces them.
enum SignalHandler {
    /// Marked `nonisolated(unsafe)` because it guards process-global C signal handler
    /// registration, which has no actor to belong to. Access is confined to picker
    /// setup/teardown on a single thread.
    nonisolated(unsafe) private static var isHandlerSet = false

    /// Registers signal handlers for SIGINT (Control+C) and SIGTERM.
    ///
    /// The handlers the host application had installed are saved so `removeSignalHandlers()`
    /// can put them back. This method is idempotent — calling it multiple times has no effect
    /// if handlers are already registered, so the saved host handlers are never overwritten
    /// with the picker's own. The cleanup closure will be executed when a termination signal
    /// is received, before the signal is forwarded to the host's saved handler.
    ///
    /// - Parameter cleanup: The cleanup closure to execute on signal receipt
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

        // Register handlers for both SIGINT (Ctrl+C) and SIGTERM (kill command),
        // saving whatever the host had installed
        sigaction(SIGINT, &action, &previousInterruptAction)
        sigaction(SIGTERM, &action, &previousTerminateAction)
    }

    /// Removes the signal handlers and cleanup closure.
    ///
    /// Restores the handlers the host application had installed before `setupSignalHandlers`
    /// ran — `SIG_DFL`, `SIG_IGN`, or a custom handler — rather than resetting to the system
    /// default, so a host's own interrupt handling keeps working after the picker closes.
    /// Does nothing if no handlers are registered.
    static func removeSignalHandlers() {
        guard isHandlerSet else { return }

        sigaction(SIGINT, &previousInterruptAction, nil)
        sigaction(SIGTERM, &previousTerminateAction, nil)
        globalCleanupHandler = nil
        isHandlerSet = false
    }

    /// Responds to a received SIGINT or SIGTERM. Called by the installed C signal handler;
    /// separate from it so tests can drive the response without sending real signals, which
    /// a debugger attached to the test runner would intercept.
    ///
    /// When a termination signal is received, this function:
    /// 1. Executes the registered cleanup closure (if any)
    /// 2. Marks the picker as interrupted (see `wasInterrupted`)
    /// 3. Forwards the signal according to the host's saved action (see `SignalForwarding`)
    ///
    /// - Parameters:
    ///   - signal: The signal number
    ///   - info: Signal details, passed through to a chained `SA_SIGINFO` host handler
    ///   - context: Thread context, passed through to a chained `SA_SIGINFO` host handler
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

    /// Whether SIGINT or SIGTERM arrived since the handlers were last set up.
    ///
    /// When the host handles the signal itself, the process keeps running after the
    /// terminal is restored, so the input loop checks this to stop drawing and finish.
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
    ///
    /// - Parameter previousAction: The action the host had installed before the picker
    /// - Returns: How the picker's handler forwards the signal after restoring the terminal
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
/// Global cleanup handler storage.
///
/// Required because C signal handlers (`signal()`) cannot capture Swift closures or context.
/// This must be at file scope to be accessible from the C signal handler function, which
/// is why it is `nonisolated(unsafe)` — a C function pointer cannot carry actor isolation.
nonisolated(unsafe) private var globalCleanupHandler: (() -> Void)?

/// The host's SIGINT and SIGTERM actions, saved by `setupSignalHandlers` and restored by
/// `removeSignalHandlers`. File scope and `nonisolated(unsafe)` for the same reason as
/// `globalCleanupHandler`.
nonisolated(unsafe) private var previousInterruptAction = sigaction()
nonisolated(unsafe) private var previousTerminateAction = sigaction()

/// Set by the signal handler, cleared by `setupSignalHandlers`. `sig_atomic_t` because it is
/// written from signal context; file scope and `nonisolated(unsafe)` like the storage above.
nonisolated(unsafe) private var interruptReceived: sig_atomic_t = 0

/// C signal handler function for SIGINT and SIGTERM. Delegates to `SignalHandler.handle`.
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
