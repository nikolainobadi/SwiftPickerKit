//
//  CommandLineSelection.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Interactive single- and multi-selection pickers.
///
/// Arrow keys move, Enter confirms, and `q` cancels; in multi-selection, Space toggles an item.
/// Ctrl+C or SIGTERM, when the host keeps running, finishes as a cancel or blocks, per
/// `PickerInterruptBehavior`. `PickerLayout` selects a single-column or two-column layout.
public protocol CommandLineSelection {
    /// Displays a picker for selecting a single item.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: The items to choose from
    ///   - layout: Single-column or two-column layout
    ///   - newScreen: If `true`, uses the alternate screen buffer
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: The selected item, or `nil` if cancelled
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> Item?

    /// Displays a picker for selecting multiple items.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - items: The items to choose from
    ///   - layout: Single-column or two-column layout
    ///   - newScreen: If `true`, uses the alternate screen buffer
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: The selected items; empty if cancelled or nothing was selected
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

    /// Displays a single-selection picker and throws if nothing is selected.
    ///
    /// - Throws: `PickerInterruptedError` if a `SwiftPicker` prompt is ended by Ctrl+C or SIGTERM
    ///   while the host keeps running; otherwise `SwiftPickerError.selectionCancelled` if cancelled
    /// - Returns: The selected item
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) throws -> Item {
        guard let value = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText) else {
            if let interruption = PickerInterruptedError.interruption(for: self) {
                throw interruption
            }

            throw SwiftPickerError.selectionCancelled
        }
        return value
    }

    /// Convenience overload of `requiredSingleSelection(prompt:items:layout:newScreen:showSelectedItemText:)`
    /// with default parameter values and unlabeled prompt.
    ///
    /// - Throws: `PickerInterruptedError` if interrupted while the host keeps running;
    ///   otherwise `SwiftPickerError.selectionCancelled` if cancelled
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
