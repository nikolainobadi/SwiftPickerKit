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


// MARK: - BaseSelectionState
extension TwoColumnDynamicDetailState: BaseSelectionState {
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

    var showSelectedItemText: Bool {
        return leftState.showSelectedItemText
    }

    func toggleSelection(at index: Int) {
        leftState.toggleSelection(at: index)
    }
}
