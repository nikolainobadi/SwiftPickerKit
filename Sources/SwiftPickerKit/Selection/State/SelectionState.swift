//
//  SelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionState<Item: DisplayablePickerItem> {
    let prompt: String
    let isSingleSelection: Bool

    var options: [Option<Item>]
    var activeIndex: Int = 0
    var selectedItemForHeader: Item?
    var isShowingScrollUpIndicator = false

    init(options: [Option<Item>], prompt: String, isSingleSelection: Bool) {
        self.prompt = prompt
        self.options = options
        self.isSingleSelection = isSingleSelection
    }
}

// MARK: - BaseSelectionState
extension SelectionState: BaseSelectionState {
    var topLineText: String {
        return "InteractivePicker (\(isSingleSelection ? "single" : "multi")-selection)"
    }

    var bottomLineText: String {
        if isSingleSelection {
            "Tap 'enter' to select. Type 'q' to quit."
        } else {
            "Select multiple items with 'spacebar'. Tap 'enter' to finish."
        }
    }

    func toggleSelection(at index: Int) {
        guard options.indices.contains(index) else {
            return
        }
        
        options[index].isSelected.toggle()
    }
}

// MARK: - Selection Helpers
extension SelectionState {
    var selectedOptions: [Option<Item>] {
        return options.filter { $0.isSelected }
    }

    func showAsSelected(_ option: Option<Item>) -> Bool {
        if isSingleSelection {
            return false
        }
        return option.isSelected
    }
}

// MARK: - Dependencies
struct Option<Item: DisplayablePickerItem> {
    let item: Item
    var isSelected: Bool = false

    var title: String {
        return item.displayName
    }
}
