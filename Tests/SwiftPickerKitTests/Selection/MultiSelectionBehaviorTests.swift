//
//  MultiSelectionBehaviorTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct MultiSelectionBehaviorTests {
    @Test
    func `Starting values empty`() {
        let (sut, state) = makeSUT()

        #expect(state.selectedOptions.isEmpty)
        #expect(state.activeIndex == 0)

        let result = sut.handleSpecialChar(char: .backspace, state: state)
        if case .continueLoop = result {
        } else {
            Issue.record("Expected continueLoop on backspace")
        }
    }

    @Test
    func `Finishes with selected items on enter`() {
        let items = [TestFactory.makeItem(name: "First"), TestFactory.makeItem(name: "Second")]
        let (sut, state) = makeSUT(items: items, selectedIndices: [1])

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishMulti(let selected):
            #expect(selected.map { $0.displayName } == [items[1].displayName])
        default:
            Issue.record("Expected finishMulti on enter")
        }
    }

    @Test
    func `Toggles active item selection on space`() {
        let items = [TestFactory.makeItem(name: "Pick")]
        let (sut, state) = makeSUT(items: items, activeIndex: 0)

        let firstResult = sut.handleSpecialChar(char: .space, state: state)
        let firstSelection = state.options[0].isSelected

        let secondResult = sut.handleSpecialChar(char: .space, state: state)
        let secondSelection = state.options[0].isSelected

        if case .continueLoop = firstResult {} else {
            Issue.record("Expected continueLoop after first space press")
        }
        if case .continueLoop = secondResult {} else {
            Issue.record("Expected continueLoop after second space press")
        }
        #expect(firstSelection)
        #expect(secondSelection == false)
    }

    @Test
    func `Finishes with empty selection on quit`() {
        let items = [TestFactory.makeItem(name: "One"), TestFactory.makeItem(name: "Two")]
        let (sut, state) = makeSUT(items: items, selectedIndices: [0, 1])

        let result = sut.handleSpecialChar(char: .quit, state: state)

        switch result {
        case .finishMulti(let selected):
            #expect(selected.isEmpty)
        default:
            Issue.record("Expected finishMulti([]) on quit")
        }
    }
}


// MARK: - SUT
private extension MultiSelectionBehaviorTests {
    func makeSUT(items: [TestItem] = [TestFactory.makeItem(name: "Item")], activeIndex: Int = 0, selectedIndices: Set<Int> = []) -> (MultiSelectionBehavior<TestItem>, SelectionState<TestItem>) {
        var options = items.map { Option(item: $0) }
        selectedIndices.forEach { index in
            if options.indices.contains(index) {
                options[index].isSelected = true
            }
        }

        let state = SelectionState(options: options, prompt: "Prompt", isSingleSelection: false)
        state.activeIndex = activeIndex
        let sut = MultiSelectionBehavior<TestItem>()
        return (sut, state)
    }
}
