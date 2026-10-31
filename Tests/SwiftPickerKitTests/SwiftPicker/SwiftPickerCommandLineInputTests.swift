//
//  SwiftPickerCommandLineInputTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
import Foundation
@testable import SwiftPickerKit

/// Secret reads run under the process-global signal handlers (see `MockTextInput`), so the suite
/// shares the signal-state lock.
@Suite(.signalState)
struct SwiftPickerCommandLineInputTests {
    @Test
    func `Starting values empty`() {
        let (_, textInput) = makeSUT(inputResponses: [])
        #expect(textInput.capturedInputPrompts.isEmpty)
        #expect(textInput.capturedSecretPrompts.isEmpty)
    }

    @Test
    func `Returns text response when prompted for input`() {
        let prompt = "Enter project name"
        let expectedResponse = "SwiftPicker"
        let (sut, textInput) = makeSUT(inputResponses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = commandLineInput.getInput(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedInputPrompts == [prompt])
    }

    @Test
    func `Provides non-empty text when input is required`() throws {
        let expectedResponse = "value"
        let (sut, _) = makeSUT(inputResponses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = try commandLineInput.getRequiredInput(prompt: "Enter value")

        #expect(result == expectedResponse)
    }

    @Test
    func `Throws error when required input is empty`() {
        let (sut, _) = makeSUT(inputResponses: [""])
        let commandLineInput: CommandLineInput = sut

        #expect(throws: SwiftPickerError.self) {
            try commandLineInput.getRequiredInput(prompt: "Enter value")
        }
    }
}

// MARK: - Secret Input
extension SwiftPickerCommandLineInputTests {
    @Test
    func `Returns the secret typed at a secret prompt`() {
        let prompt = "Enter API token"
        let (sut, textInput) = makeSUT(secretResponses: ["s3cr3t"])
        let commandLineInput: CommandLineInput = sut

        let result = commandLineInput.getSecretInput(prompt: prompt)

        #expect(result == "s3cr3t")
        #expect(textInput.capturedSecretPrompts == [prompt])
    }

    @Test
    func `Asks secret prompts through the secret reader only`() {
        let (sut, textInput) = makeSUT(inputResponses: ["visible"], secretResponses: ["hidden"])

        _ = sut.getSecretInput("Password")

        #expect(textInput.capturedInputPrompts.isEmpty)
        #expect(sut.getInput(prompt: "Name") == "visible")
    }

    @Test
    func `Provides non-empty secret when secret input is required`() throws {
        let (sut, _) = makeSUT(secretResponses: ["s3cr3t"])

        let result = try sut.getRequiredSecretInput(prompt: "Password")

        #expect(result == "s3cr3t")
    }

    @Test
    func `Throws input required when a required secret is empty`() {
        let (sut, _) = makeSUT(secretResponses: [""])

        #expect(throws: SwiftPickerError.inputRequired) {
            try sut.getRequiredSecretInput(prompt: "Password")
        }
    }

    @Test
    func `Throws interrupted when a required secret prompt is interrupted`() {
        withIgnoredInterrupts {
            let (sut, _) = makeSUT(onSecretRead: deliverInterrupt)

            #expect(throws: PickerInterruptedError()) {
                try sut.getRequiredSecretInput(prompt: "Password")
            }
        }
    }

    @Test
    func `Returns empty when a secret prompt is interrupted`() {
        withIgnoredInterrupts {
            let (sut, _) = makeSUT(secretResponses: [""], onSecretRead: deliverInterrupt)

            #expect(sut.getSecretInput(prompt: "Password").isEmpty)
        }
    }

    @Test
    func `Waits for termination when a secret prompt is interrupted`() {
        withIgnoredInterrupts {
            var waitCount = 0
            let (sut, _) = makeSUT(onSecretRead: deliverInterrupt, waitForTermination: { waitCount += 1 })

            _ = sut.getSecretInput(prompt: "Password")

            #expect(waitCount == 1)
        }
    }

    @Test
    func `Does not wait for termination after an uninterrupted secret prompt`() {
        var waitCount = 0
        let (sut, _) = makeSUT(secretResponses: ["s3cr3t"], waitForTermination: { waitCount += 1 })

        _ = sut.getSecretInput(prompt: "Password")

        #expect(waitCount == 0)
    }
}

// MARK: - SUT
private extension SwiftPickerCommandLineInputTests {
    func makeSUT(inputResponses: [String] = [], secretResponses: [String] = [], onSecretRead: @escaping () -> Void = {}, waitForTermination: (() -> Void)? = nil) -> (SwiftPicker, MockTextInput) {
        let textInput = MockTextInput(inputResponses: inputResponses, secretResponses: secretResponses, onSecretRead: onSecretRead)
        let sut = SwiftPicker(textInput: textInput, pickerInput: MockPickerInput(), waitForTermination: waitForTermination)
        return (sut, textInput)
    }
}

// MARK: - Helpers
private extension SwiftPickerCommandLineInputTests {
    /// Runs `body` with SIGINT ignored by the "host", so a delivered interrupt stops at the
    /// picker's cleanup instead of reaching the test runner.
    func withIgnoredInterrupts(_ body: () -> Void) {
        withPreservedSignalHandlers {
            installIgnoringHostHandler(for: SIGINT)
            body()
        }
    }

    func deliverInterrupt() {
        SignalHandler.handle(signal: SIGINT, info: nil, context: nil)
    }
}
