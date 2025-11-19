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
    private var permissionResult: MockPermissionResult

    /// Captured prompts provide a simple way for tests to assert which strings were displayed.
    public private(set) var capturedPrompts: [String] = []
    /// Captured permission prompts mirror the text shown for yes/no questions.
    public private(set) var capturedPermissionPrompts: [String] = []

    public init(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init()
    ) {
        self.inputResult = inputResult
        self.permissionResult = permissionResult
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


// MARK: - CommandLinePermission
extension MockSwiftPicker: CommandLinePermission {
    public func getPermission(prompt: String) -> Bool {
        capturedPermissionPrompts.append(prompt)
        return permissionResult.nextResponse(for: prompt)
    }

    public func requiredPermission(prompt: String) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}
