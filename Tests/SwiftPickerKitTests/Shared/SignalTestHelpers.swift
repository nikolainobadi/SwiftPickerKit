//
//  SignalTestHelpers.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/31/26.
//

import Foundation
@testable import SwiftPickerKit

/// Runs `body`, then removes the picker's handlers and puts the test runner's own SIGINT and
/// SIGTERM handlers back. Use inside a `.signalState` suite.
func withPreservedSignalHandlers(_ body: () -> Void) {
    var originalInterrupt = sigaction()
    var originalTerminate = sigaction()
    sigaction(SIGINT, nil, &originalInterrupt)
    sigaction(SIGTERM, nil, &originalTerminate)

    defer {
        SignalHandler.removeSignalHandlers()
        sigaction(SIGINT, &originalInterrupt, nil)
        sigaction(SIGTERM, &originalTerminate, nil)
    }

    body()
}

/// Installs `SIG_IGN` as the "host" handler, so a signal delivered through
/// `SignalHandler.handle` stops at the picker's cleanup instead of reaching the test runner.
func installIgnoringHostHandler(for signalNumber: Int32) {
    var action = sigaction()
    action.__sigaction_u.__sa_handler = SIG_IGN
    sigemptyset(&action.sa_mask)
    action.sa_flags = 0
    sigaction(signalNumber, &action, nil)
}

/// The raw address of the handler currently installed for `signalNumber`.
func currentHandlerAddress(for signalNumber: Int32) -> Int {
    var action = sigaction()
    sigaction(signalNumber, nil, &action)
    return handlerAddress(of: action.__sigaction_u.__sa_handler)
}

/// The raw address of `handler`, comparable against `SIG_DFL` (0) and `SIG_IGN` (1).
func handlerAddress(of handler: sig_t?) -> Int {
    guard let handler else { return 0 }
    return unsafeBitCast(handler, to: Int.self)
}
