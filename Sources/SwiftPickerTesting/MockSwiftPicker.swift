//
//  MockSwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import SwiftPickerKit

/// A `CommandLinePicker` that answers from configured results and records every prompt, for
/// testing consumers without terminal I/O. `open` so tests can subclass it.
open class MockSwiftPicker {
    private var inputResult: MockInputResult
    private var secretInputResult: MockInputResult
    private var permissionResult: MockPermissionResult
    private var selectionResult: MockSelectionResult
    private var treeNavigationResult: MockTreeNavigationResult

    /// Prompts passed to `getInput`, in call order.
    public private(set) var capturedPrompts: [String] = []
    /// Prompts passed to `getSecretInput`, kept apart from `capturedPrompts`.
    public private(set) var capturedSecretPrompts: [String] = []
    /// Prompts passed to `getPermission`, in call order.
    public private(set) var capturedPermissionPrompts: [String] = []
    /// Prompts passed to `singleSelection`, in call order.
    public private(set) var capturedSingleSelectionPrompts: [String] = []
    /// Prompts passed to `multiSelection`, in call order.
    public private(set) var capturedMultiSelectionPrompts: [String] = []
    /// Prompts passed to `treeNavigation`, in call order.
    public private(set) var capturedTreeNavigationPrompts: [String] = []

    public init(
        inputResult: MockInputResult = .init(),
        secretInputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        treeNavigationResult: MockTreeNavigationResult = .init()
    ) {
        self.inputResult = inputResult
        self.secretInputResult = secretInputResult
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

    public func getSecretInput(prompt: String) -> String {
        capturedSecretPrompts.append(prompt)

        return secretInputResult.nextResponse(for: prompt)
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
    public func treeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, showPromptText: Bool, showSelectedItemText: Bool) -> Item? {
        capturedTreeNavigationPrompts.append(prompt)
        let response = treeNavigationResult.nextOutcome(for: prompt)

        guard let rootIndex = response.selectedRootIndex, root.children.indices.contains(rootIndex) else {
            return nil
        }

        let rootSelection = root.children[rootIndex]

        guard let childIndex = response.selectedChildIndex else {
            return rootSelection
        }

        let children = rootSelection.loadChildren()
        guard children.indices.contains(childIndex) else {
            return nil
        }

        return children[childIndex]
    }
}
