//
//  CommandLinePicker+FlagHint.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Foundation

// Overloads of the `required*` methods that name the command line flag a caller can pass instead
// of answering the prompt, throwing `PickerRequirementError` rather than `SwiftPickerError`.
//
// `flagHint` deliberately has no default: with one, Swift's overload ranking would prefer the
// existing method (fewer defaulted arguments) and these would be unreachable.

// MARK: - CommandLineInput
public extension CommandLineInput {
    /// Prompts for a line of text and throws, naming `flagHint`, if it is empty.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text to display
    ///   - flagHint: The command line flag that supplies this value, e.g. `"--name"`
    /// - Throws: `PickerRequirementError.missingInput` if input is empty
    /// - Returns: The user's input (guaranteed non-empty)
    func getRequiredInput(prompt: String, flagHint: String) throws -> String {
        let input = getInput(prompt: prompt)

        guard !input.isEmpty else {
            throw PickerRequirementError.missingInput(prompt: prompt, flagHint: flagHint)
        }

        return input
    }
}

// MARK: - CommandLinePermission
public extension CommandLinePermission {
    /// Asks a yes/no question and throws, naming `flagHint`, unless the user answers yes.
    ///
    /// - Parameters:
    ///   - prompt: The question to ask the user
    ///   - flagHint: The command line flag that grants this permission, e.g. `"--force"`
    /// - Throws: `PickerRequirementError.confirmationRequired` if permission is denied
    func requiredPermission(prompt: String, flagHint: String) throws {
        guard getPermission(prompt: prompt) else {
            throw PickerRequirementError.confirmationRequired(prompt: prompt, flagHint: flagHint)
        }
    }
}

// MARK: - CommandLineSelection
public extension CommandLineSelection {
    /// Displays a single-selection picker and throws, naming `flagHint`, if nothing is selected.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: The items to choose from
    ///   - flagHint: The command line flag that supplies this selection, e.g. `"--project"`
    ///   - layout: Single-column or two-column layout
    ///   - newScreen: If `true`, uses the alternate screen buffer
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `PickerInterruptedError` if a `SwiftPicker` prompt is ended by Ctrl+C or SIGTERM
    ///   while the host keeps running; otherwise `PickerRequirementError.missingSelection`
    /// - Returns: The selected item
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], flagHint: String, layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText) else {
            if let interruption = PickerInterruptedError.interruption(for: self) {
                throw interruption
            }

            throw PickerRequirementError.missingSelection(prompt: prompt, flagHint: flagHint)
        }

        return selection
    }

    /// Displays a multi-selection picker and throws, naming `flagHint`, if nothing is selected.
    ///
    /// An empty result is treated as failure because `multiSelection` cannot distinguish "chose
    /// nothing" from "could not prompt"; use `multiSelection` directly to allow an empty result.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: The items to choose from
    ///   - flagHint: The command line flag that supplies these selections, e.g. `"--target"`
    ///   - layout: Single-column or two-column layout
    ///   - newScreen: If `true`, uses the alternate screen buffer
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `PickerInterruptedError` if a `SwiftPicker` prompt is ended by Ctrl+C or SIGTERM
    ///   while the host keeps running; otherwise `PickerRequirementError.missingSelection`
    /// - Returns: The selected items (guaranteed non-empty)
    func requiredMultiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], flagHint: String, layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> [Item] {
        let selections = multiSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)

        guard !selections.isEmpty else {
            if let interruption = PickerInterruptedError.interruption(for: self) {
                throw interruption
            }

            throw PickerRequirementError.missingSelection(prompt: prompt, flagHint: flagHint)
        }

        return selections
    }
}

// MARK: - CommandLineTreeNavigation
public extension CommandLineTreeNavigation {
    /// Displays a tree navigation picker and throws, naming `flagHint`, if nothing is selected.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - root: The root container wrapping initial tree items
    ///   - flagHint: The command line flag that supplies this selection, e.g. `"--path"`
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `PickerInterruptedError` if a `SwiftPicker` prompt is ended by Ctrl+C or SIGTERM
    ///   while the host keeps running; otherwise `PickerRequirementError.missingSelection`
    /// - Returns: The selected item
    func requiredTreeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, flagHint: String, showPromptText: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = treeNavigation(prompt: prompt, root: root, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText) else {
            if let interruption = PickerInterruptedError.interruption(for: self) {
                throw interruption
            }

            throw PickerRequirementError.missingSelection(prompt: prompt, flagHint: flagHint)
        }

        return selection
    }
}
