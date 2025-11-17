//
//  SelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionState<Item: DisplayablePickerItem> {
    let topLine: Int
    let prompt: String
    let isSingleSelection: Bool

    var activeLine: Int
    var options: [Option<Item>]

    // Header-rendering state
    var selectedItemForHeader: Item?
    var isShowingScrollUpIndicator: Bool = false

    init(options: [Option<Item>], topLine: Int, prompt: String, isSingleSelection: Bool) {
        self.prompt = prompt
        self.options = options
        self.topLine = topLine
        self.activeLine = topLine      // first option is at this line
        self.isSingleSelection = isSingleSelection
    }
}


// MARK: - Helper Methods
extension SelectionState {
    var selectedOptions: [Option<Item>] {
        options.filter { $0.isSelected }
    }

    var rangeOfLines: (minimum: Int, maximum: Int) {
        (topLine, topLine + options.count - 1)
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

    func toggleSelection(at line: Int) {
        if let i = options.firstIndex(where: { $0.line == line }) {
            options[i].isSelected.toggle()
        }
    }

    func showAsSelected(_ option: Option<Item>) -> Bool {
        isSingleSelection ? option.line == activeLine : option.isSelected
    }
}


// MARK: - Dependencies
struct Option<Item: DisplayablePickerItem> {
    let item: Item
    let line: Int
    var isSelected: Bool = false

    var title: String {
        item.displayName
    }
}
