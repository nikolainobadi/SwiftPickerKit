//
//  TwoColumnDynamicDetailState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TwoColumnDynamicDetailState<Item: DisplayablePickerItem> {
    var leftState: SelectionState<Item>
    let detailForItem: (Item) -> String

    init(leftState: SelectionState<Item>, detailForItem: @escaping (Item) -> String) {
        self.leftState = leftState
        self.detailForItem = detailForItem
    }
}

extension TwoColumnDynamicDetailState: BaseSelectionState {
    var activeIndex: Int {
        get { leftState.activeIndex }
        set { leftState.activeIndex = newValue }
    }

    var options: [Option<Item>] { leftState.options }
    var prompt: String { leftState.prompt }
    var topLineText: String { leftState.topLineText }
    var bottomLineText: String { leftState.bottomLineText }

    func toggleSelection(at index: Int) {
        leftState.toggleSelection(at: index)
    }
}
