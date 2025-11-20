//
//  TwoColumnDynamicDetailSingleBehaviorTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TwoColumnDynamicDetailSingleBehaviorTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (sut, state) = makeSUT()

        #expect(state.activeIndex == 0)
        #expect(state.options.count == 1)

        let backspace = sut.handleSpecialChar(char: .backspace, state: state)
        let space = sut.handleSpecialChar(char: .space, state: state)

        if case .continueLoop = backspace {} else {
            Issue.record("Expected continueLoop on backspace")
        }
        if case .continueLoop = space {} else {
            Issue.record("Expected continueLoop on space")
        }
    }

    @Test("Finishes with active item on enter")
    func finishesWithActiveItemOnEnter() {
        let items = [TestFactory.makeItem(name: "First"), TestFactory.makeItem(name: "Second")]
        let (sut, state) = makeSUT(items: items, activeIndex: 1)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishSingle(let item):
            #expect(item?.displayName == items[1].displayName)
        default:
            Issue.record("Expected finishSingle with active item")
        }
    }

    @Test("Finishes with nil on quit")
    func finishesWithNilOnQuit() {
        let items = [TestFactory.makeItem(name: "QuitItem")]
        let (sut, state) = makeSUT(items: items)

        let result = sut.handleSpecialChar(char: .quit, state: state)

        switch result {
        case .finishSingle(let item):
            #expect(item == nil)
        default:
            Issue.record("Expected finishSingle(nil) on quit")
        }
    }
}


// MARK: - SUT
private extension TwoColumnDynamicDetailSingleBehaviorTests {
    func makeSUT(items: [TestItem] = [TestFactory.makeItem(name: "Item")], activeIndex: Int = 0, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (TwoColumnDynamicDetailSingleBehavior<TestItem>, TwoColumnDynamicDetailState<TestItem>) {
        let options = items.map { Option(item: $0) }
        let left = SelectionState(options: options, prompt: "Prompt", isSingleSelection: true)
        left.activeIndex = activeIndex
        let state = TwoColumnDynamicDetailState(leftState: left, detailForItem: { _ in "Detail" })
        let sut = TwoColumnDynamicDetailSingleBehavior<TestItem>()
        return (sut, state)
    }
}
