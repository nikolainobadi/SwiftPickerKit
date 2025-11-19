//
//  SwiftPickerCommandLineInputTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineInputTests {
    @Test("CommandLineInput getInput returns text input response")
    func commandLineInputGetInputReturnsTextInputResponse() {
        let prompt = "Enter project name"
        let expectedResponse = "SwiftPicker"
        let (sut, textInput) = makeSUT(responses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = commandLineInput.getInput(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedPrompts == [prompt])
    }

    @Test("CommandLineInput getRequiredInput returns non-empty response")
    func commandLineInputGetRequiredInputReturnsNonEmptyResponse() throws {
        let expectedResponse = "value"
        let (sut, _) = makeSUT(responses: [expectedResponse])
        let commandLineInput: CommandLineInput = sut

        let result = try commandLineInput.getRequiredInput(prompt: "Enter value")

        #expect(result == expectedResponse)
    }

    @Test("CommandLineInput getRequiredInput throws when response is empty")
    func commandLineInputGetRequiredInputThrowsWhenResponseIsEmpty() {
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

private struct NoOpPickerInput: PickerInput {
    func cursorOff() {}
    func moveRight() {}
    func moveToHome() {}
    func clearBuffer() {}
    func clearScreen() {}
    func enableNormalInput() {}
    func keyPressed() -> Bool { false }
    func write(_ text: String) {}
    func exitAlternativeScreen() {}
    func enterAlternativeScreen() {}
    func moveTo(_ row: Int, _ col: Int) {}
    func readDirectionKey() -> Direction? { nil }
    func readSpecialChar() -> SpecialChar? { nil }
    func readCursorPos() -> (row: Int, col: Int) { (0, 0) }
    func readScreenSize() -> (rows: Int, cols: Int) { (0, 0) }
}


// MARK: - Helpers
private func makeSUT(responses: [String]) -> (SwiftPicker, StubTextInput) {
    let textInput = StubTextInput(responses: responses)
    let sut = SwiftPicker(textInput: textInput, pickerInput: NoOpPickerInput())
    return (sut, textInput)
}
