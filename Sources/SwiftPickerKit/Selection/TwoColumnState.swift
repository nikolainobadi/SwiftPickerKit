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
    var left: SelectionState<Item>

    /// Secondary display items (right side)
    var rightItems: [Item]

    init(left: SelectionState<Item>, rightItems: [Item]) {
        self.left = left
        self.rightItems = rightItems
    }
}

// MARK: - BaseSelectionState Conformance
extension TwoColumnState: BaseSelectionState {
    var activeIndex: Int {
        get { left.activeIndex }
        set { left.activeIndex = newValue }
    }

    var options: [Option<Item>] {
        left.options
    }

    var prompt: String {
        left.prompt
    }

    var topLineText: String {
        left.topLineText
    }

    var bottomLineText: String {
        left.bottomLineText
    }

    func toggleSelection(at index: Int) {
        left.toggleSelection(at: index)
    }
}
