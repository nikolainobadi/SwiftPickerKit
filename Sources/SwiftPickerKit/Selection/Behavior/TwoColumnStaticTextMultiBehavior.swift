//
//  TwoColumnStaticTextMultiBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TwoColumnStaticTextMultiBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    func handleSpecialChar(char: SpecialChar, state: TwoColumnStaticTextState<Item>) -> SelectionOutcome<Item> {
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
