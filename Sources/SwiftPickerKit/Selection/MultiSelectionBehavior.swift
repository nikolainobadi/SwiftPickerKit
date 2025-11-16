//
//  MultiSelectionBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct MultiSelectionBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    func handleSpecialChar(char: SpecialChar, state: SelectionState<Item>) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            return .finishMulti(state.selectedOptions.map { $0.item })
        case .space:
            state.toggleSelection(at: state.activeLine)
            return .continueLoop
        case .quit:
            return .finishMulti([])
        case .backspace:
            return .continueLoop
        }
    }
}
