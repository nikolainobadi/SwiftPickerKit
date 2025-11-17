//
//  SelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionState<Item: DisplayablePickerItem> {
    let prompt: String
    let isSingleSelection: Bool

    // Model
    var options: [Option<Item>]
    var activeIndex: Int = 0

    // Header state
    var selectedItemForHeader: Item?
    var isShowingScrollUpIndicator = false

    init(options: [Option<Item>], prompt: String, isSingleSelection: Bool) {
        self.prompt = prompt
        self.options = options
        self.isSingleSelection = isSingleSelection
    }
}

extension SelectionState {
    var selectedOptions: [Option<Item>] {
        options.filter { $0.isSelected }
    }

    var topLineText: String {
        "InteractivePicker (\(isSingleSelection ? "single" : "multi")-selection)"
    }

    var bottomLineText: String {
        if isSingleSelection {
            "Tap 'enter' to select. Type 'q' to quit."
        } else {
            "Select multiple items with 'spacebar'. Tap 'enter' to finish."
        }
    }

    func toggleSelection(at index: Int) {
        guard options.indices.contains(index) else { return }
        options[index].isSelected.toggle()
    }

    func showAsSelected(_ option: Option<Item>) -> Bool {
        if isSingleSelection {
            return false // single selection only highlights activeIndex
        }
        return option.isSelected
    }
}


// MARK: - Dependencies
struct Option<Item: DisplayablePickerItem> {
    let item: Item
    var isSelected: Bool = false

    var title: String { item.displayName }
}
