//
//  TwoColumnState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// State for two-column layout with independent left/right columns.
/// The left column acts as the primary selection target.
final class TwoColumnState<Item: DisplayablePickerItem> {
    /// Primary selection column (left side)
    var leftState: SelectionState<Item>

    /// Secondary display items (right side)
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
