//
//  NonInteractivePicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Foundation

/// A `CommandLinePicker` that never prompts.
///
/// Every interactive primitive returns its "nothing was provided" value, which means the
/// existing `required*` extensions throw exactly as they would when a user cancels. Use this
/// in scripted, piped, or CI contexts where there is no one available to answer a prompt.
///
/// ## Usage
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
/// ## Guarantees
///
/// Never blocks and never waits on a human: no terminal I/O, no signal handlers, and no
/// alternate screen buffer. Every method returns immediately.
///
/// These guarantees cover terminal interaction only — see the `browseDirectories` caveat below
/// for the one path that touches the file system and process-global state.
///
/// - Important: `browseDirectories` always returns `nil`, but reaching it through
///   `any CommandLinePicker` or a generic `some CommandLinePicker` with the trailing arguments
///   omitted binds to the convenience overload in `CommandLineTreeNavigation` rather than to the
///   member below. That overload reads one directory listing from disk and assigns
///   `FileSystemNode.selectionType` before delegating here, so the call is neither free of I/O
///   nor free of side effects on that path. Only the return value is unaffected.
///
///   This cannot be prevented from outside `CommandLineTreeNavigation`: default arguments on a
///   protocol extension member bind statically, and the protocol requirement declares none.
///   Passing every argument explicitly, or holding a concrete `NonInteractivePicker`, avoids it.
public struct NonInteractivePicker: CommandLinePicker, Sendable {
    private let assumeYes: Bool

    /// Creates a picker that declines every prompt.
    ///
    /// - Parameter assumeYes: When `true`, permission prompts resolve to `true` instead of
    ///   `false`. This is the `--yes` / `--assume-yes` behavior common to scripted tools.
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

    /// Returns an empty array. Use `requiredMultiSelection(prompt:items:flagHint:)` when an
    /// empty result should be treated as a failure rather than a deliberate empty selection.
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
    /// The defaults mirror the convenience overload in `CommandLineTreeNavigation` so that
    /// call sites holding a concrete `NonInteractivePicker` bind here and skip the directory
    /// read that overload performs.
    func browseDirectories(prompt: String, startURL: URL, showPromptText: Bool = true, showSelectedItemText: Bool = true, selectionType: FileSystemNode.SelectionType = .filesAndFolders) -> FileSystemNode? {
        return nil
    }
}
