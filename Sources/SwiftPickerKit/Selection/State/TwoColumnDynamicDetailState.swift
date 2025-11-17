//
//  TwoColumnDynamicDetailState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TwoColumnDynamicDetailState<Item: DisplayablePickerItem> {
    var left: SelectionState<Item>
    let detailForItem: (Item) -> String

    init(left: SelectionState<Item>, detailForItem: @escaping (Item) -> String) {
        self.left = left
        self.detailForItem = detailForItem
    }
}

extension TwoColumnDynamicDetailState: BaseSelectionState {
    var activeIndex: Int {
        get { left.activeIndex }
        set { left.activeIndex = newValue }
    }

    var options: [Option<Item>] { left.options }
    var prompt: String { left.prompt }
    var topLineText: String { left.topLineText }
    var bottomLineText: String { left.bottomLineText }

    func toggleSelection(at index: Int) {
        left.toggleSelection(at: index)
    }
}
