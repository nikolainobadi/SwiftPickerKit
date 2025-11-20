//
//  TreeNavigationBehaviorTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TreeNavigationBehaviorTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let roots = TestFactory.makeTreeItems(names: ["Root"])
        let (sut, state) = makeSUT(rootItems: roots)

        #expect(state.activeIndex == 0)
        #expect(state.options.count == roots.count)
        #expect(sut.allowSelectingFolders)

        let result = sut.handleSpecialChar(char: .backspace, state: state)
        if case .continueLoop = result {} else {
            Issue.record("Expected continueLoop on backspace")
        }
    }

    @Test("Moves up and clamps at start of list")
    func movesUpAndClampsAtStartOfList() {
        let roots = TestFactory.makeTreeItems(names: ["Root 1", "Root 2"])
        let (sut, state) = makeSUT(rootItems: roots)
        state.activeIndex = 0

        var mutableState = state
        sut.handleArrow(direction: .up, state: &mutableState)

        #expect(mutableState.activeIndex == 0)
    }

    @Test("Moves down and clamps at end of list")
    func movesDownAndClampsAtEndOfList() {
        let roots = TestFactory.makeTreeItems(names: ["Root 1", "Root 2"])
        let (sut, state) = makeSUT(rootItems: roots)
        state.activeIndex = roots.count - 1

        var mutableState = state
        sut.handleArrow(direction: .down, state: &mutableState)

        #expect(mutableState.activeIndex == roots.count - 1)
    }

    @Test("Descends into children on right arrow")
    func descendsIntoChildrenOnRightArrow() {
        let children = TestFactory.makeTreeItems(names: ["Child 1", "Child 2"])
        let roots = [TestFactory.makeTreeItem(name: "Root", children: children)]
        let (sut, state) = makeSUT(rootItems: roots)

        var mutableState = state
        sut.handleArrow(direction: .right, state: &mutableState)

        #expect(mutableState.currentItems.map(\.displayName) == children.map(\.displayName))
        #expect(mutableState.activeIndex == 0)
    }

    @Test("Ascends to parent on left arrow")
    func ascendsToParentOnLeftArrow() {
        let children = TestFactory.makeTreeItems(names: ["Child"])
        let roots = [TestFactory.makeTreeItem(name: "Root", children: children)]
        let (sut, state) = makeSUT(rootItems: roots)

        var mutableState = state
        sut.handleArrow(direction: .right, state: &mutableState)
        sut.handleArrow(direction: .left, state: &mutableState)

        #expect(mutableState.currentItems.map(\.displayName) == roots.map(\.displayName))
    }

    @Test("Enter selects folders when allowed")
    func enterSelectsFoldersWhenAllowed() {
        let roots = [TestFactory.makeTreeItem(name: "Root", children: TestFactory.makeTreeItems(names: ["Child"]))]
        let (sut, state) = makeSUT(rootItems: roots, allowSelectingFolders: true)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishSingle(let item):
            #expect(item?.displayName == roots[0].displayName)
        default:
            Issue.record("Expected finishSingle with folder when allowed")
        }
    }

    @Test("Enter skips folders when not allowed")
    func enterSkipsFoldersWhenNotAllowed() {
        let roots = [TestFactory.makeTreeItem(name: "Root", children: TestFactory.makeTreeItems(names: ["Child"]))]
        let (sut, state) = makeSUT(rootItems: roots, allowSelectingFolders: false)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        if case .continueLoop = result {} else {
            Issue.record("Expected continueLoop when selecting folder is disallowed")
        }
    }

    @Test("Enter selects leaf when folders disallowed")
    func enterSelectsLeafWhenFoldersDisallowed() {
        let leaves = TestFactory.makeTreeItems(names: ["Leaf"])
        let (sut, state) = makeSUT(rootItems: leaves, allowSelectingFolders: false)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishSingle(let item):
            #expect(item?.displayName == leaves[0].displayName)
        default:
            Issue.record("Expected finishSingle with leaf")
        }
    }

    @Test("Enter continues when no items available")
    func enterContinuesWhenNoItemsAvailable() {
        let (sut, state) = makeSUT(rootItems: [], allowSelectingFolders: true)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        if case .continueLoop = result {} else {
            Issue.record("Expected continueLoop when no items exist")
        }
    }

    @Test("Quit finishes with nil")
    func quitFinishesWithNil() {
        let (sut, state) = makeSUT()

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
private extension TreeNavigationBehaviorTests {
    func makeSUT(rootItems: [TreeTestItem] = TestFactory.makeTreeItems(names: ["Root"]), allowSelectingFolders: Bool = true) -> (TreeNavigationBehavior<TreeTestItem>, TreeNavigationState<TreeTestItem>) {
        let state = TreeNavigationState(rootItems: rootItems, prompt: "Prompt")
        let sut = TreeNavigationBehavior<TreeTestItem>(allowSelectingFolders: allowSelectingFolders)
        return (sut, state)
    }
}
