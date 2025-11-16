//
//  SingleSelectionBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct SingleSelectionBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    func handleSpecialChar(char: SpecialChar, state: SelectionState<Item>) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let item = state.options.first(where: { $0.line == state.activeLine })?.item
            return .finishSingle(item)
        case .quit:
            return .finishSingle(nil)
        case .space, .backspace:
            return .continueLoop
        }
    }
}
