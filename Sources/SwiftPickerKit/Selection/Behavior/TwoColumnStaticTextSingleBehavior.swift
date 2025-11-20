//
//  TwoColumnStaticTextSingleBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TwoColumnStaticTextSingleBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = TwoColumnStaticTextState<Item>

    func handleSpecialChar(
        char: SpecialChar,
        state: State
    ) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let left = state.leftState
            let item = left.options[left.activeIndex].item
            return .finishSingle(item)

        case .quit:
            return .finishSingle(nil)

        case .space, .backspace:
            return .continueLoop
        }
    }
}
