//
//  SignalHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation

/// A utility for handling termination signals (SIGINT, SIGTERM) to ensure proper terminal cleanup.
enum SignalHandler {
    private static var isHandlerSet = false

    /// Registers signal handlers for SIGINT (Control+C) and SIGTERM.
    /// Ensures terminal cleanup occurs even if the program is interrupted.
    /// - Parameter cleanup: The cleanup closure to execute on signal receipt.
    static func setupSignalHandlers(cleanup: @escaping () -> Void) {
        guard !isHandlerSet else { return }

        globalCleanupHandler = cleanup
        isHandlerSet = true

        // Set up signal handlers
        signal(SIGINT, signalHandler)
        signal(SIGTERM, signalHandler)
    }

    /// Removes the signal handlers and cleanup closure.
    static func removeSignalHandlers() {
        signal(SIGINT, SIG_DFL)
        signal(SIGTERM, SIG_DFL)
        globalCleanupHandler = nil
        isHandlerSet = false
    }
}


// MARK: - Dependencies
// Global cleanup handler storage (required because signal() cannot capture context)
private var globalCleanupHandler: (() -> Void)?

/// Signal handler function for SIGINT and SIGTERM
private func signalHandler(_ signal: Int32) {
    globalCleanupHandler?()
    exit(130) // Standard exit code for SIGINT
}
