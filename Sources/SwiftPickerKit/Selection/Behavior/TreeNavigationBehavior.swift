//
//  TreeNavigationBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TreeNavigationBehavior<Item: TreeNodePickerItem> {
    typealias State = TreeNavigationState<Item>
}


// MARK: - SelectionBehavior
extension TreeNavigationBehavior: SelectionBehavior {
    func handleArrow(direction: Direction, state: inout State) {
        switch direction {
        case .up:
            state.activeIndex -= 1
            state.clampIndex()
        case .down:
            state.activeIndex += 1
            state.clampIndex()
        case .right:
            state.descendIntoChildIfPossible()
        case .left:
            state.ascendToParent()
        }
    }

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .space:
            return .continueLoop
        case .backspace:
            return .continueLoop
        case .enter:
            guard !state.currentItems.isEmpty else {
                return .continueLoop
            }
            
            let selected = state.currentItems[state.activeIndex]
            guard selected.isSelectable else {
                return .continueLoop
            }

            return .finishSingle(selected)
        case .quit:
            return .finishSingle(nil)
        }
    }
}
