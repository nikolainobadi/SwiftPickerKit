//
//  SingleSelectionBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct SingleSelectionBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = SelectionState<Item>

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let item = state.options[state.activeIndex].item

            return .finishSingle(item)
        case .quit:
            return .finishSingle(nil)
        case .space, .backspace:
            return .continueLoop
        }
    }
}
