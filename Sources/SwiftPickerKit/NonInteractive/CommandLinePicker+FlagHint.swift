//
//  CommandLinePicker+FlagHint.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Foundation

// Additive overloads of the `required*` methods that name the command line flag a caller can
// pass instead of answering the prompt. They sit alongside the existing methods rather than
// replacing them, so call sites opt in one at a time.
//
// `flagHint` deliberately has no default value on any of these. With a default, the new overload
// and the existing one are both viable for a call that omits it, and Swift's overload ranking
// prefers the candidate applying fewer default arguments — the existing method would win and
// these would be unreachable. Requiring the argument makes the opt-in explicit.

// MARK: - CommandLineInput
public extension CommandLineInput {
    /// Required input variant that names the flag a caller can pass instead.
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
    /// Required permission variant that names the flag a caller can pass instead.
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
    /// Required single selection variant that names the flag a caller can pass instead.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: Array of items conforming to `DisplayablePickerItem`
    ///   - flagHint: The command line flag that supplies this selection, e.g. `"--project"`
    ///   - layout: The picker layout (single column or two-column)
    ///   - newScreen: If `true`, uses alternate screen buffer
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `PickerRequirementError.missingSelection` if nothing was selected
    /// - Returns: The selected item (guaranteed non-nil)
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], flagHint: String, layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText) else {
            throw PickerRequirementError.missingSelection(prompt: prompt, flagHint: flagHint)
        }

        return selection
    }

    /// Required multi selection variant that throws when nothing was selected.
    ///
    /// `multiSelection` cannot distinguish "the user chose nothing" from "nothing could be
    /// prompted for" — both return an empty array. This variant treats empty as a failure so a
    /// scripted run reports an error instead of silently proceeding with zero items. Callers
    /// that want to allow an empty result should use `multiSelection` directly.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: Array of items conforming to `DisplayablePickerItem`
    ///   - flagHint: The command line flag that supplies these selections, e.g. `"--target"`
    ///   - layout: The picker layout (single column or two-column)
    ///   - newScreen: If `true`, uses alternate screen buffer
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `PickerRequirementError.missingSelection` if no items were selected
    /// - Returns: The selected items (guaranteed non-empty)
    func requiredMultiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], flagHint: String, layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> [Item] {
        let selections = multiSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)

        guard !selections.isEmpty else {
            throw PickerRequirementError.missingSelection(prompt: prompt, flagHint: flagHint)
        }

        return selections
    }
}


// MARK: - CommandLineTreeNavigation
public extension CommandLineTreeNavigation {
    /// Required tree navigation variant that names the flag a caller can pass instead.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - root: The root container wrapping initial tree items
    ///   - flagHint: The command line flag that supplies this selection, e.g. `"--path"`
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `PickerRequirementError.missingSelection` if nothing was selected
    /// - Returns: The selected item
    func requiredTreeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, flagHint: String, showPromptText: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = treeNavigation(prompt: prompt, root: root, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText) else {
            throw PickerRequirementError.missingSelection(prompt: prompt, flagHint: flagHint)
        }

        return selection
    }
}
