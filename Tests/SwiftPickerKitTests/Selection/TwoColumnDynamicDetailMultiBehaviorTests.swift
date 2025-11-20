//
//  TwoColumnDynamicDetailMultiBehaviorTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TwoColumnDynamicDetailMultiBehaviorTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (sut, state) = makeSUT()

        #expect(state.activeIndex == 0)
        #expect(state.options.allSatisfy { $0.isSelected == false })

        let result = sut.handleSpecialChar(char: .backspace, state: state)
        if case .continueLoop = result {} else {
            Issue.record("Expected continueLoop on backspace")
        }
    }

    @Test("Finishes with selected items on enter")
    func finishesWithSelectedItemsOnEnter() {
        let items = [TestFactory.makeItem(name: "First"), TestFactory.makeItem(name: "Second")]
        let (sut, state) = makeSUT(items: items, selectedIndices: [0, 1])

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishMulti(let selected):
            #expect(Set(selected.map { $0.displayName }) == Set(items.map { $0.displayName }))
        default:
            Issue.record("Expected finishMulti on enter")
        }
    }

    @Test("Toggles selection at active index on space")
    func togglesSelectionAtActiveIndexOnSpace() {
        let items = [TestFactory.makeItem(name: "Pick")]
        let (sut, state) = makeSUT(items: items, activeIndex: 0)

        let first = sut.handleSpecialChar(char: .space, state: state)
        let firstSelection = state.options[0].isSelected
        let second = sut.handleSpecialChar(char: .space, state: state)
        let secondSelection = state.options[0].isSelected

        if case .continueLoop = first {} else {
            Issue.record("Expected continueLoop after first space")
        }
        if case .continueLoop = second {} else {
            Issue.record("Expected continueLoop after second space")
        }
        #expect(firstSelection)
        #expect(secondSelection == false)
    }

    @Test("Finishes with empty list on quit")
    func finishesWithEmptyListOnQuit() {
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
private extension TwoColumnDynamicDetailMultiBehaviorTests {
    func makeSUT(items: [TestItem] = [TestFactory.makeItem(name: "Item")], activeIndex: Int = 0, selectedIndices: Set<Int> = []) -> (TwoColumnDynamicDetailMultiBehavior<TestItem>, TwoColumnDynamicDetailState<TestItem>) {
        var options = items.map { Option(item: $0) }
        selectedIndices.forEach { index in
            if options.indices.contains(index) {
                options[index].isSelected = true
            }
        }

        let left = SelectionState(options: options, prompt: "Prompt", isSingleSelection: false)
        left.activeIndex = activeIndex
        let state = TwoColumnDynamicDetailState(leftState: left, detailForItem: { _ in "Detail" })
        let sut = TwoColumnDynamicDetailMultiBehavior<TestItem>()
        return (sut, state)
    }
}
