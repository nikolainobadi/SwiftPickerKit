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
        let (_, textInput) = makeSUT(inputResponses: [])
        #expect(textInput.capturedInputPrompts.isEmpty)
    }

    @Test("Returns text response when prompted for input")
    func returnsTextResponseWhenPromptedForInput() {
        let prompt = "Enter project name"
        let expectedResponse = "SwiftPicker"
        let (sut, textInput) = makeSUT(inputResponses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = commandLineInput.getInput(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedInputPrompts == [prompt])
    }

    @Test("Provides non-empty text when input is required")
    func providesNonEmptyTextWhenInputIsRequired() throws {
        let expectedResponse = "value"
        let (sut, _) = makeSUT(inputResponses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = try commandLineInput.getRequiredInput(prompt: "Enter value")

        #expect(result == expectedResponse)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() {
        let (sut, _) = makeSUT(inputResponses: [""])
        let commandLineInput: CommandLineInput = sut

        #expect(throws: SwiftPickerError.self) {
            try commandLineInput.getRequiredInput(prompt: "Enter value")
        }
    }
}


// MARK: - Helpers
private func makeSUT(inputResponses: [String]) -> (SwiftPicker, MockTextInput) {
    let textInput = MockTextInput(inputResponses: inputResponses)
    let sut = SwiftPicker(textInput: textInput, pickerInput: MockPickerInput())
    return (sut, textInput)
}
