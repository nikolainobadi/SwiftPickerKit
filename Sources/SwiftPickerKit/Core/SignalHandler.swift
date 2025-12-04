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
/// When these signals are received, it executes the cleanup closure to restore terminal state
/// before exiting.
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
/// entire process.
enum SignalHandler {
    private static var isHandlerSet = false

    /// Registers signal handlers for SIGINT (Control+C) and SIGTERM.
    ///
    /// This method is idempotent — calling it multiple times has no effect if handlers
    /// are already registered. The cleanup closure will be executed when a termination
    /// signal is received, followed by process exit with code 130 (standard for SIGINT).
    ///
    /// - Parameter cleanup: The cleanup closure to execute on signal receipt
    static func setupSignalHandlers(cleanup: @escaping () -> Void) {
        guard !isHandlerSet else { return }

        globalCleanupHandler = cleanup
        isHandlerSet = true

        // Register handlers for both SIGINT (Ctrl+C) and SIGTERM (kill command)
        signal(SIGINT, signalHandler)
        signal(SIGTERM, signalHandler)
    }

    /// Removes the signal handlers and cleanup closure.
    ///
    /// Restores default signal handling behavior. Always call this after picker operations
    /// complete to avoid interfering with other parts of the application.
    static func removeSignalHandlers() {
        signal(SIGINT, SIG_DFL)   // Restore default SIGINT handler
        signal(SIGTERM, SIG_DFL)  // Restore default SIGTERM handler
        globalCleanupHandler = nil
        isHandlerSet = false
    }
}


// MARK: - Private Implementation
/// Global cleanup handler storage.
///
/// Required because C signal handlers (`signal()`) cannot capture Swift closures or context.
/// This must be at file scope to be accessible from the C signal handler function.
private var globalCleanupHandler: (() -> Void)?

/// C signal handler function for SIGINT and SIGTERM.
///
/// When a termination signal is received, this function:
/// 1. Executes the registered cleanup closure (if any)
/// 2. Exits the process with code 130 (standard exit code for SIGINT)
///
/// - Parameter signal: The signal number (unused, but required by signal API)
private func signalHandler(_ signal: Int32) {
    globalCleanupHandler?()
    exit(130)
}
