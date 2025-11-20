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
            let selected = state.options
                .filter { $0.isSelected }
                .map { $0.item }
            
            return .finishMulti(selected)
        case .space:
            state.toggleSelection(at: state.activeIndex)
            return .continueLoop
        case .quit:
            return .finishMulti([])
        case .backspace:
            return .continueLoop
        }
    }
}
