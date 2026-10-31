//
//  NonInteractivePicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Foundation

/// A `CommandLinePicker` for scripted, piped, or CI runs that never prompts.
///
/// Every primitive returns its "nothing provided" value, so the `required*` methods throw as they
/// would on a user cancel. No terminal I/O, signal handlers, or alternate screen; every method
/// returns immediately.
///
/// ```swift
/// let picker: any CommandLinePicker = isInteractive
///     ? SwiftPicker()
///     : NonInteractivePicker(assumeYes: assumeYes)
///
/// // Throws instead of hanging when nothing can be prompted for.
/// let name = try picker.getRequiredInput(prompt: "Project name", flagHint: "--name")
/// ```
///
/// - Important: `browseDirectories` always returns `nil`, but calling it through
///   `any CommandLinePicker` or a generic `some CommandLinePicker` with trailing arguments omitted
///   binds statically to the `CommandLineTreeNavigation` convenience overload, which reads one
///   directory listing and sets `FileSystemNode.selectionType` before delegating here. Pass every
///   argument, or hold a concrete `NonInteractivePicker`, to avoid that I/O and side effect.
public struct NonInteractivePicker: CommandLinePicker, Sendable {
    private let assumeYes: Bool

    /// Creates a picker that declines every prompt.
    ///
    /// - Parameter assumeYes: When `true`, permission prompts return `true` (the usual `--yes`
    ///   behavior) instead of `false`.
    public init(assumeYes: Bool = false) {
        self.assumeYes = assumeYes
    }
}

// MARK: - CommandLineInput
public extension NonInteractivePicker {
    /// Returns an empty string, so `getRequiredInput` throws `SwiftPickerError.inputRequired`.
    func getInput(prompt: String) -> String {
        return ""
    }

    /// Returns an empty string, so `getRequiredSecretInput` throws `SwiftPickerError.inputRequired`.
    func getSecretInput(prompt: String) -> String {
        return ""
    }
}

// MARK: - CommandLinePermission
public extension NonInteractivePicker {
    /// Returns the configured `assumeYes` value without prompting.
    func getPermission(prompt: String) -> Bool {
        return assumeYes
    }
}

// MARK: - CommandLineSelection
public extension NonInteractivePicker {
    /// Returns `nil`, so `requiredSingleSelection` throws `SwiftPickerError.selectionCancelled`.
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> Item? {
        return nil
    }

    /// Returns an empty array; use `requiredMultiSelection(prompt:items:flagHint:)` to treat that
    /// as a failure.
    func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> [Item] {
        return []
    }
}

// MARK: - CommandLineTreeNavigation
public extension NonInteractivePicker {
    /// Returns `nil`, so `requiredTreeNavigation` throws `SwiftPickerError.selectionCancelled`.
    func treeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, showPromptText: Bool, showSelectedItemText: Bool) -> Item? {
        return nil
    }

    /// Returns `nil` without touching the file system.
    ///
    /// The defaults mirror the `CommandLineTreeNavigation` convenience overload so calls on a
    /// concrete `NonInteractivePicker` bind here and skip its directory read.
    func browseDirectories(prompt: String, startURL: URL, showPromptText: Bool = true, showSelectedItemText: Bool = true, selectionType: FileSystemNode.SelectionType = .filesAndFolders) -> FileSystemNode? {
        return nil
    }
}
