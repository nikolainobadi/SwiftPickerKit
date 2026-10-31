//
//  BaseSelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Data a picker exposes to its behavior and renderer; holds no input or drawing logic.
protocol BaseSelectionState<Item> {
    associatedtype Item: DisplayablePickerItem

    /// Index of the highlighted item.
    var activeIndex: Int { get set }

    /// Items with their multi-selection status; single-selection states leave every option unselected.
    var options: [Option<Item>] { get }

    /// Header prompt; may span several lines separated by `\n`.
    var prompt: String { get }

    var topLineText: String { get }

    /// Footer instructions.
    var bottomLineText: String { get }

    /// Extra header lines under the selected item. Defaults to none.
    var selectedDetailLines: [String] { get }

    /// Whether the header shows the "Selected:" block. Defaults to `true`.
    var showSelectedItemText: Bool { get }

    /// Whether the header shows the prompt. Defaults to `true`.
    var showPromptText: Bool { get }

    /// Toggles selection for multi-selection states. Defaults to a no-op.
    func toggleSelection(at index: Int)
}

extension BaseSelectionState {
    var selectedDetailLines: [String] { [] }

    var showSelectedItemText: Bool { true }

    var showPromptText: Bool { true }

    func toggleSelection(at index: Int) { }
}

/// A state whose focused item may not be `options[activeIndex]`, such as a tree's parent column.
protocol FocusAwareSelectionState<Item>: BaseSelectionState {
    /// The item the header should describe.
    var focusedItem: Item? { get }
}
