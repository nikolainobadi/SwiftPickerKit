//
//  TwoColumnState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// State for a two-column layout where only the left column takes selection.
final class TwoColumnState<Item: DisplayablePickerItem> {
    var leftState: SelectionState<Item>

    /// Display-only items for the right column.
    var rightItems: [Item]

    init(leftState: SelectionState<Item>, rightItems: [Item]) {
        self.leftState = leftState
        self.rightItems = rightItems
    }
}

// MARK: - BaseSelectionState Conformance
extension TwoColumnState: BaseSelectionState {
    var activeIndex: Int {
        get { leftState.activeIndex }
        set { leftState.activeIndex = newValue }
    }

    var options: [Option<Item>] {
        return leftState.options
    }

    var prompt: String {
        return leftState.prompt
    }

    var topLineText: String {
        return leftState.topLineText
    }

    var bottomLineText: String {
        return leftState.bottomLineText
    }

    func toggleSelection(at index: Int) {
        leftState.toggleSelection(at: index)
    }
}
