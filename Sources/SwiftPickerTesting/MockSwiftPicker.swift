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
    private var selectionResult: MockSelectionResult

    /// Captured prompts provide a simple way for tests to assert which strings were displayed.
    public private(set) var capturedPrompts: [String] = []
    /// Captured permission prompts mirror the text shown for yes/no questions.
    public private(set) var capturedPermissionPrompts: [String] = []
    /// Captured single selection prompts mirror the picker request text.
    public private(set) var capturedSingleSelectionPrompts: [String] = []
    /// Captured multi selection prompts mirror the picker request text.
    public private(set) var capturedMultiSelectionPrompts: [String] = []

    public init(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init()
    ) {
        self.inputResult = inputResult
        self.permissionResult = permissionResult
        self.selectionResult = selectionResult
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


// MARK: - CommandLineSelection
extension MockSwiftPicker: CommandLineSelection {
    public func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool) -> Item? {
        capturedSingleSelectionPrompts.append(prompt)
        let response = selectionResult.nextSingleOutcome(for: prompt)

        guard let index = response.selectedIndex, items.indices.contains(index) else {
            return nil
        }

        return items[index]
    }

    public func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool) throws -> Item {
        guard let value = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen) else {
            throw SwiftPickerError.selectionCancelled
        }

        return value
    }

    public func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool) -> [Item] {
        capturedMultiSelectionPrompts.append(prompt)
        let response = selectionResult.nextMultiOutcome(for: prompt)

        return response.selectedIndices.compactMap { index in
            guard items.indices.contains(index) else {
                return nil
            }
            return items[index]
        }
    }
}
