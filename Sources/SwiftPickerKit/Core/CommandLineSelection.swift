//
//  CommandLineSelection.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Public interface for single and multi-selection pickers.
///
/// This protocol defines the core selection picker APIs. Types conforming to this protocol
/// (like `SwiftPicker`) can display interactive pickers that let users select one or more
/// items from a list.
///
/// ## Single Selection
///
/// Single-selection pickers allow users to choose exactly one item:
/// - Navigate with arrow keys
/// - Press Enter to confirm selection
/// - Press 'q' or Ctrl+C to cancel
/// - Returns the selected item (or nil if cancelled)
///
/// ## Multi-Selection
///
/// Multi-selection pickers allow users to choose zero or more items:
/// - Navigate with arrow keys
/// - Press Space to toggle selection (adds checkmark)
/// - Press Enter to confirm all selections
/// - Press 'q' or Ctrl+C to cancel
/// - Always returns an array (empty if cancelled or no selections made)
///
/// ## Layout Options
///
/// All picker methods support three layout modes via `PickerLayout`:
/// - `.singleColumn` — Simple vertical list
/// - `.twoColumnStatic(detailText:)` — List with persistent detail panel on the right
/// - `.twoColumnDynamic(detailForItem:)` — List with dynamic detail panel that updates per item
public protocol CommandLineSelection {
    /// Displays an interactive picker for selecting a single item.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: Array of items conforming to `DisplayablePickerItem`
    ///   - layout: The picker layout (single column or two-column)
    ///   - newScreen: If `true`, uses alternate screen buffer (recommended for clean UX)
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: The selected item, or `nil` if the user cancelled
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> Item?

    /// Displays an interactive picker for selecting multiple items.
    ///
    /// Users toggle selections with Space bar and confirm with Enter. An empty array
    /// is returned if the user cancels or makes no selections.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: Array of items conforming to `DisplayablePickerItem`
    ///   - layout: The picker layout (single column or two-column)
    ///   - newScreen: If `true`, uses alternate screen buffer (recommended for clean UX)
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: Array of selected items (empty if cancelled or no selections)
    func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> [Item]
}


// MARK: - CommandLineSelection Convenience
public extension CommandLineSelection {
    /// Convenience overload with default parameter values.
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) -> Item? {
        return singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }

    /// Convenience overload with unlabeled prompt parameter.
    func singleSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) -> Item? {
        return singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }

    /// Required variant that throws if the user cancels.
    ///
    /// Use this when a selection is mandatory for your workflow. If the user cancels
    /// (presses 'q' or Ctrl+C), this method throws `SwiftPickerError.selectionCancelled`.
    ///
    /// - Throws: `SwiftPickerError.selectionCancelled` if user cancels
    /// - Returns: The selected item (guaranteed non-nil)
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) throws -> Item {
        guard let value = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText) else {
            throw SwiftPickerError.selectionCancelled
        }
        return value
    }

    /// Required variant with default parameter values and unlabeled prompt.
    ///
    /// - Throws: `SwiftPickerError.selectionCancelled` if user cancels
    /// - Returns: The selected item (guaranteed non-nil)
    func requiredSingleSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        return try requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }

    /// Convenience overload with default parameter values.
    func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) -> [Item] {
        return multiSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }

    /// Convenience overload with unlabeled prompt parameter.
    func multiSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) -> [Item] {
        return multiSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }
}
