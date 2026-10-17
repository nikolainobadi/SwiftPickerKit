//
//  SignalHandlerTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation
import Testing
@testable import SwiftPickerKit

/// Signal dispositions are process-global, so these tests run serialized and put the
/// test runner's real handlers back when each one finishes.
@Suite(.serialized, .signalState)
struct SignalHandlerTests {
    @Test(arguments: [SIGINT, SIGTERM])
    func `Restores an ignored host handler after removal`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(SIG_IGN, for: signalNumber)

            SignalHandler.setupSignalHandlers(cleanup: {})
            SignalHandler.removeSignalHandlers()

            #expect(currentHandlerAddress(for: signalNumber) == address(of: SIG_IGN))
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Restores a custom host handler after removal`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(hostHandler, for: signalNumber)

            SignalHandler.setupSignalHandlers(cleanup: {})
            SignalHandler.removeSignalHandlers()

            #expect(currentHandlerAddress(for: signalNumber) == address(of: hostHandler))
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Restores the default handler after removal`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(SIG_DFL, for: signalNumber)

            SignalHandler.setupSignalHandlers(cleanup: {})
            SignalHandler.removeSignalHandlers()

            #expect(currentHandlerAddress(for: signalNumber) == address(of: SIG_DFL))
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Replaces the host handler while the picker is active`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(SIG_IGN, for: signalNumber)

            SignalHandler.setupSignalHandlers(cleanup: {})
            let activeHandler = currentHandlerAddress(for: signalNumber)
            SignalHandler.removeSignalHandlers()

            #expect(activeHandler != address(of: SIG_IGN))
            #expect(activeHandler != address(of: SIG_DFL))
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Repeated setup still restores the original host handler`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(hostHandler, for: signalNumber)

            SignalHandler.setupSignalHandlers(cleanup: {})
            SignalHandler.setupSignalHandlers(cleanup: {})
            SignalHandler.removeSignalHandlers()

            #expect(currentHandlerAddress(for: signalNumber) == address(of: hostHandler))
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Removal without setup leaves the host handler untouched`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(hostHandler, for: signalNumber)

            SignalHandler.removeSignalHandlers()

            #expect(currentHandlerAddress(for: signalNumber) == address(of: hostHandler))
        }
    }
}


// MARK: - Forwarding Decision
extension SignalHandlerTests {
    @Test
    func `Re-raises when the host had the default handler`() {
        let action = makeAction(handler: SIG_DFL)

        #expect(SignalHandler.forwarding(for: action) == .reraiseDefault)
    }

    @Test
    func `Leaves the signal to the host when the host ignores it`() {
        let action = makeAction(handler: SIG_IGN)

        #expect(SignalHandler.forwarding(for: action) == .leaveToHost)
    }

    @Test
    func `Chains to a custom host handler`() {
        let action = makeAction(handler: hostHandler)

        #expect(SignalHandler.forwarding(for: action) == .chainToHandler)
    }

    @Test
    func `Chains to a custom host handler that uses siginfo`() {
        let action = makeInfoAction(handler: hostInfoHandler)

        #expect(SignalHandler.forwarding(for: action) == .chainToHandler)
    }
}


// MARK: - Signal Response
/// These call `SignalHandler.handle` directly instead of sending real signals: a debugger
/// attached to the test runner (Xcode's default) stops on SIGINT and SIGTERM, which hangs the run.
extension SignalHandlerTests {
    @Test(arguments: [SIGINT, SIGTERM])
    func `Restores the terminal and leaves an ignored signal to the host`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(SIG_IGN, for: signalNumber)
            SignalHandler.setupSignalHandlers(cleanup: { deliveryLog.append("cleanup") })

            SignalHandler.handle(signal: signalNumber, info: nil, context: nil)

            #expect(deliveryLog == ["cleanup"])
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Restores the terminal before calling a custom host handler`(signalNumber: Int32) {
        withPreservedHandlers {
            installHostHandler(hostHandler, for: signalNumber)
            SignalHandler.setupSignalHandlers(cleanup: { deliveryLog.append("cleanup") })

            SignalHandler.handle(signal: signalNumber, info: nil, context: nil)

            #expect(deliveryLog == ["cleanup", "host \(signalNumber)"])
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Restores the terminal before calling a custom siginfo host handler`(signalNumber: Int32) {
        withPreservedHandlers {
            var action = makeInfoAction(handler: hostInfoHandler)
            sigaction(signalNumber, &action, nil)
            SignalHandler.setupSignalHandlers(cleanup: { deliveryLog.append("cleanup") })

            SignalHandler.handle(signal: signalNumber, info: nil, context: nil)

            #expect(deliveryLog == ["cleanup", "host info \(signalNumber)"])
        }
    }
}


// MARK: - Helpers
private extension SignalHandlerTests {
    func withPreservedHandlers(_ body: () -> Void) {
        var originalInterrupt = sigaction()
        var originalTerminate = sigaction()
        sigaction(SIGINT, nil, &originalInterrupt)
        sigaction(SIGTERM, nil, &originalTerminate)

        deliveryLog = []

        defer {
            SignalHandler.removeSignalHandlers()
            sigaction(SIGINT, &originalInterrupt, nil)
            sigaction(SIGTERM, &originalTerminate, nil)
            deliveryLog = []
        }

        body()
    }

    func installHostHandler(_ handler: sig_t?, for signalNumber: Int32) {
        var action = makeAction(handler: handler)
        sigaction(signalNumber, &action, nil)
    }

    func makeAction(handler: sig_t?) -> sigaction {
        var action = sigaction()
        action.__sigaction_u.__sa_handler = handler
        sigemptyset(&action.sa_mask)
        action.sa_flags = 0
        return action
    }

    func makeInfoAction(handler: @escaping @convention(c) (Int32, UnsafeMutablePointer<__siginfo>?, UnsafeMutableRawPointer?) -> Void) -> sigaction {
        var action = sigaction()
        action.__sigaction_u.__sa_sigaction = handler
        sigemptyset(&action.sa_mask)
        action.sa_flags = SA_SIGINFO
        return action
    }

    func currentHandlerAddress(for signalNumber: Int32) -> Int {
        var action = sigaction()
        sigaction(signalNumber, nil, &action)
        return address(of: action.__sigaction_u.__sa_handler)
    }

    func address(of handler: sig_t?) -> Int {
        guard let handler else { return 0 }
        return unsafeBitCast(handler, to: Int.self)
    }
}


// MARK: - Host Handlers
/// Records the order in which the picker's cleanup and the chained host handler run.
/// `nonisolated(unsafe)` because signal handlers write to it; the suite is serialized.
nonisolated(unsafe) private var deliveryLog: [String] = []

/// Stands in for a host application's own C signal handler.
private func hostHandler(_ signal: Int32) {
    deliveryLog.append("host \(signal)")
}

/// Stands in for a host application's own `SA_SIGINFO` signal handler.
private func hostInfoHandler(_ signal: Int32, _ info: UnsafeMutablePointer<__siginfo>?, _ context: UnsafeMutableRawPointer?) {
    deliveryLog.append("host info \(signal)")
}
