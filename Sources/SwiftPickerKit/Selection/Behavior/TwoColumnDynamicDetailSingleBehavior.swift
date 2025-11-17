//
//  TwoColumnDynamicDetailSingleBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TwoColumnDynamicDetailSingleBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = TwoColumnDynamicDetailState<Item>

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let item = state.left.options[state.activeIndex].item
            return .finishSingle(item)

        case .quit:
            return .finishSingle(nil)

        case .space, .backspace:
            return .continueLoop
        }
    }
}
