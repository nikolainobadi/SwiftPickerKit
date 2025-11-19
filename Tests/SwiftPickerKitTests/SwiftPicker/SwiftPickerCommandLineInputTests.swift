//
//  SwiftPickerCommandLineInputTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineInputTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, textInput) = makeSUT(responses: [])
        #expect(textInput.capturedPrompts.isEmpty)
    }

    @Test("Returns text response when prompted for input")
    func returnsTextResponseWhenPromptedForInput() {
        let prompt = "Enter project name"
        let expectedResponse = "SwiftPicker"
        let (sut, textInput) = makeSUT(responses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = commandLineInput.getInput(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedPrompts == [prompt])
    }

    @Test("Provides non-empty text when input is required")
    func providesNonEmptyTextWhenInputIsRequired() throws {
        let expectedResponse = "value"
        let (sut, _) = makeSUT(responses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = try commandLineInput.getRequiredInput(prompt: "Enter value")

        #expect(result == expectedResponse)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() {
        let (sut, _) = makeSUT(responses: [""])
        let commandLineInput: CommandLineInput = sut

        #expect(throws: SwiftPickerError.self) {
            try commandLineInput.getRequiredInput(prompt: "Enter value")
        }
    }
}


// MARK: - Test Doubles
private final class StubTextInput: TextInput {
    private var responses: [String]
    private(set) var capturedPrompts: [String] = []

    init(responses: [String]) {
        self.responses = responses
    }

    func getInput(_ prompt: String) -> String {
        capturedPrompts.append(prompt)
        guard !responses.isEmpty else { return "" }
        return responses.removeFirst()
    }

    func getPermission(_ prompt: String) -> Bool {
        return true
    }
}

// MARK: - Helpers
private func makeSUT(responses: [String]) -> (SwiftPicker, StubTextInput) {
    let textInput = StubTextInput(responses: responses)
    let sut = SwiftPicker(textInput: textInput, pickerInput: MockPickerInput())
    return (sut, textInput)
}
