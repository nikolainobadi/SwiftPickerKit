//
//  MockSwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import SwiftPickerKit

/// Lightweight mock that mirrors the `CommandLineInput` surface so clients can unit test
/// flows that expect a picker-like dependency without touching STDIN.
public final class MockSwiftPicker {
    private var inputResult: MockInputResult

    /// Captured prompts provide a simple way for tests to assert which strings were displayed.
    public private(set) var capturedPrompts: [String] = []

    public init(inputResult: MockInputResult = .init()) {
        self.inputResult = inputResult
    }
}


// MARK: - CommandLineInput
extension MockSwiftPicker: CommandLineInput {
    public func getInput(prompt: String) -> String {
        capturedPrompts.append(prompt)

        return inputResult.nextResponse(for: prompt)
    }

    public func getRequiredInput(prompt: String) throws -> String {
        let value = getInput(prompt: prompt)
        guard !value.isEmpty else {
            throw SwiftPickerError.inputRequired
        }
        return value
    }
}
