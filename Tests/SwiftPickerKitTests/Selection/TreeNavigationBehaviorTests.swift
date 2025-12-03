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

    @Test("Left arrow focuses parent column before ascending")
    func leftArrowFocusesParentColumnBeforeAscending() {
        let children = TestFactory.makeTreeItems(names: ["Child"])
        let roots = [TestFactory.makeTreeItem(name: "Root", children: children)]
        let (sut, state) = makeSUT(rootItems: roots)

        var mutableState = state
        sut.handleArrow(direction: .right, state: &mutableState)
        sut.handleArrow(direction: .left, state: &mutableState) // switch to parent column

        #expect(mutableState.isParentColumnActive)
        #expect(mutableState.currentItems.map(\.displayName) == children.map(\.displayName))

        sut.handleArrow(direction: .left, state: &mutableState) // now ascend

        #expect(mutableState.currentItems.map(\.displayName) == roots.map(\.displayName))
    }

    @Test("Parent navigation updates current column children")
    func parentNavigationUpdatesCurrentColumnChildren() {
        let firstChildren = TestFactory.makeTreeItems(names: ["First Child"])
        let secondChildren = TestFactory.makeTreeItems(names: ["Second Child 1", "Second Child 2"])
        let roots = [
            TestFactory.makeTreeItem(name: "First Root", children: firstChildren),
            TestFactory.makeTreeItem(name: "Second Root", children: secondChildren)
        ]
        let (sut, state) = makeSUT(rootItems: roots)

        var mutableState = state
        sut.handleArrow(direction: .right, state: &mutableState) // enter first root
        sut.handleArrow(direction: .left, state: &mutableState) // focus parent column
        sut.handleArrow(direction: .down, state: &mutableState) // move to second root

        #expect(mutableState.isParentColumnActive)
        #expect(mutableState.currentItems.map(\.displayName) == secondChildren.map(\.displayName))
    }

    @Test("Hidden root does not surface in parent column")
    func hiddenRootDoesNotSurfaceInParentColumn() {
        let children = TestFactory.makeTreeItems(names: ["Child 1", "Child 2"])
        let roots = [TestFactory.makeTreeItem(name: "Root", children: children)]
        let (sut, state) = makeSUT(rootItems: roots)

        var mutableState = state
        mutableState.startAtRootContentsIfNeeded()

        #expect(mutableState.isCurrentColumnActive)
        #expect(mutableState.parentLevelInfo == nil)

        sut.handleArrow(direction: .left, state: &mutableState) // should not reveal root
        #expect(mutableState.currentItems.map(\.displayName) == children.map(\.displayName))
    }

    @Test("Enter selects selectable folders")
    func enterSelectsSelectableFolders() {
        let roots = [TestFactory.makeTreeItem(name: "Root", children: TestFactory.makeTreeItems(names: ["Child"]))]
        let (sut, state) = makeSUT(rootItems: roots)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishSingle(let item):
            #expect(item?.displayName == roots[0].displayName)
        default:
            Issue.record("Expected finishSingle with selectable folder")
        }
    }

    @Test("Enter skips non-selectable folders")
    func enterSkipsNonSelectableFolders() {
        let roots = [TestFactory.makeTreeItem(
            name: "Root",
            children: TestFactory.makeTreeItems(names: ["Child"]),
            isSelectable: false
        )]
        let (sut, state) = makeSUT(rootItems: roots)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        if case .continueLoop = result {} else {
            Issue.record("Expected continueLoop when folder is not selectable")
        }
    }

    @Test("Enter selects leaf nodes")
    func enterSelectsLeafNodes() {
        let leaves = TestFactory.makeTreeItems(names: ["Leaf"])
        let (sut, state) = makeSUT(rootItems: leaves)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        switch result {
        case .finishSingle(let item):
            #expect(item?.displayName == leaves[0].displayName)
        default:
            Issue.record("Expected finishSingle with leaf")
        }
    }

    @Test("Enter skips non-selectable items")
    func enterSkipsNonSelectableItems() {
        let leaves = [TestFactory.makeTreeItem(name: "Leaf", isSelectable: false)]
        let (sut, state) = makeSUT(rootItems: leaves)

        let result = sut.handleSpecialChar(char: .enter, state: state)

        if case .continueLoop = result {} else {
            Issue.record("Expected continueLoop when item is not selectable")
        }
    }

    @Test("Enter continues when no items available")
    func enterContinuesWhenNoItemsAvailable() {
        let (sut, state) = makeSUT(rootItems: [])

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
    func makeSUT(rootItems: [TreeTestItem] = TestFactory.makeTreeItems(names: ["Root"])) -> (TreeNavigationBehavior<TreeTestItem>, TreeNavigationState<TreeTestItem>) {
        let state = TreeNavigationState(rootItems: rootItems, prompt: "Prompt")
        let sut = TreeNavigationBehavior<TreeTestItem>()
        return (sut, state)
    }
}
