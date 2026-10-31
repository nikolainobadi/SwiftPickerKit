//
//  HiddenLineReaderTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/31/26.
//

import Testing
import Foundation
@testable import SwiftPickerKit

/// Reads run under the process-global signal handlers, so these share the signal-state lock and
/// put the test runner's real handlers back after each test. Interrupts are delivered by calling
/// `SignalHandler.handle` with an ignoring host handler, so nothing reaches the test runner.
@Suite(.serialized, .signalState)
struct HiddenLineReaderTests {
    @Test
    func `Returns the line that was read`() {
        withPreservedSignalHandlers {
            let (sut, _) = makeSUT(lineSource: { "hunter2" })

            #expect(sut.readLine() == "hunter2")
        }
    }

    @Test
    func `Returns nil at end of input`() {
        withPreservedSignalHandlers {
            let (sut, _) = makeSUT(lineSource: { nil })

            #expect(sut.readLine() == nil)
        }
    }

    @Test
    func `Turns echo off for the read and back on afterwards`() {
        withPreservedSignalHandlers {
            let echo = MockTerminalEcho()
            let sut = HiddenLineReader(echo: echo, lineSource: {
                echo.events.append("read")
                return "secret"
            })

            _ = sut.readLine()

            #expect(echo.events == ["disable", "read", "restore"])
        }
    }

    @Test
    func `Restores echo as soon as an interrupt arrives mid-read`() {
        withPreservedSignalHandlers {
            installIgnoringHostHandler(for: SIGINT)
            let echo = MockTerminalEcho()
            let sut = HiddenLineReader(echo: echo, lineSource: {
                SignalHandler.handle(signal: SIGINT, info: nil, context: nil)
                echo.events.append("read interrupted")
                return nil
            })

            _ = sut.readLine()

            #expect(echo.events.prefix(3) == ["disable", "restore", "read interrupted"])
        }
    }

    @Test
    func `Reports an interrupt that arrives mid-read`() {
        withPreservedSignalHandlers {
            installIgnoringHostHandler(for: SIGTERM)
            let (sut, _) = makeSUT(lineSource: {
                SignalHandler.handle(signal: SIGTERM, info: nil, context: nil)
                return nil
            })

            _ = sut.readLine()

            #expect(SignalHandler.wasInterrupted)
        }
    }

    @Test
    func `Clears an interrupt left over from an earlier prompt`() {
        withPreservedSignalHandlers {
            installIgnoringHostHandler(for: SIGINT)
            SignalHandler.setupSignalHandlers(cleanup: {})
            SignalHandler.handle(signal: SIGINT, info: nil, context: nil)
            SignalHandler.removeSignalHandlers()
            let (sut, _) = makeSUT(lineSource: { "secret" })

            _ = sut.readLine()

            #expect(!SignalHandler.wasInterrupted)
        }
    }

    @Test(arguments: [SIGINT, SIGTERM])
    func `Puts the host signal handler back after the read`(signalNumber: Int32) {
        withPreservedSignalHandlers {
            installIgnoringHostHandler(for: signalNumber)
            let (sut, _) = makeSUT(lineSource: { "secret" })

            _ = sut.readLine()

            #expect(currentHandlerAddress(for: signalNumber) == handlerAddress(of: SIG_IGN))
        }
    }

    @Test
    func `Handles signals while the read is in progress`() {
        withPreservedSignalHandlers {
            installIgnoringHostHandler(for: SIGINT)
            var activeHandler = 0
            let (sut, _) = makeSUT(lineSource: {
                activeHandler = currentHandlerAddress(for: SIGINT)
                return "secret"
            })

            _ = sut.readLine()

            #expect(activeHandler != handlerAddress(of: SIG_IGN))
            #expect(activeHandler != handlerAddress(of: SIG_DFL))
        }
    }
}

// MARK: - SUT
private extension HiddenLineReaderTests {
    func makeSUT(lineSource: @escaping () -> String?) -> (HiddenLineReader, MockTerminalEcho) {
        let echo = MockTerminalEcho()
        let sut = HiddenLineReader(echo: echo, lineSource: lineSource)
        return (sut, echo)
    }
}

// MARK: - Mocks
private final class MockTerminalEcho: TerminalEcho {
    var events: [String] = []

    func disable() {
        events.append("disable")
    }

    func restore() {
        events.append("restore")
    }
}
