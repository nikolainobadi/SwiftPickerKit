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
    private var treeNavigationResult: MockTreeNavigationResult

    /// Captured prompts provide a simple way for tests to assert which strings were displayed.
    public private(set) var capturedPrompts: [String] = []
    /// Captured permission prompts mirror the text shown for yes/no questions.
    public private(set) var capturedPermissionPrompts: [String] = []
    /// Captured single selection prompts mirror the picker request text.
    public private(set) var capturedSingleSelectionPrompts: [String] = []
    /// Captured multi selection prompts mirror the picker request text.
    public private(set) var capturedMultiSelectionPrompts: [String] = []
    /// Captured tree navigation prompts mirror the hierarchical picker requests.
    public private(set) var capturedTreeNavigationPrompts: [String] = []

    public init(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        treeNavigationResult: MockTreeNavigationResult = .init()
    ) {
        self.inputResult = inputResult
        self.permissionResult = permissionResult
        self.selectionResult = selectionResult
        self.treeNavigationResult = treeNavigationResult
    }
}


// MARK: - CommandLineInput
extension MockSwiftPicker: CommandLineInput {
    public func getInput(prompt: String) -> String {
        capturedPrompts.append(prompt)

        return inputResult.nextResponse(for: prompt)
    }
}


// MARK: - CommandLinePermission
extension MockSwiftPicker: CommandLinePermission {
    public func getPermission(prompt: String) -> Bool {
        capturedPermissionPrompts.append(prompt)
        return permissionResult.nextResponse(for: prompt)
    }
}


// MARK: - CommandLineSelection
extension MockSwiftPicker: CommandLineSelection {
    public func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> Item? {
        capturedSingleSelectionPrompts.append(prompt)
        let response = selectionResult.nextSingleOutcome(for: prompt)

        guard let index = response.selectedIndex, items.indices.contains(index) else {
            return nil
        }

        return items[index]
    }

    public func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) throws -> Item {
        guard let value = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText) else {
            throw SwiftPickerError.selectionCancelled
        }

        return value
    }

    public func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> [Item] {
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


// MARK: - CommandLineTreeNavigation
extension MockSwiftPicker: CommandLineTreeNavigation {
    public func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool
    ) -> Item? {
        capturedTreeNavigationPrompts.append(prompt)
        let response = treeNavigationResult.nextOutcome(for: prompt)

        guard let index = response.selectedRootIndex, rootItems.indices.contains(index) else {
            return nil
        }

        return rootItems[index]
    }

    public func requiredTreeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool
    ) throws -> Item {
        guard let value = treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen
        ) else {
            throw SwiftPickerError.selectionCancelled
        }

        return value
    }
}
