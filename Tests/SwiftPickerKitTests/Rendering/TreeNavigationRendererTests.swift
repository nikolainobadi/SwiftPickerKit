//
//  TreeNavigationRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct TreeNavigationRendererTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test("Displays breadcrumb path when navigation depth exists")
    func displaysBreadcrumbPathWhenNavigationDepthExists() {
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: [
            TestTreeNode(name: "Child")
        ])
        let items = [rootItem]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 20)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasBreadcrumb = pickerInput.writtenText.contains { $0.contains("▸") }
        #expect(hasBreadcrumb)
    }

    @Test("Omits parent column at root level")
    func omitsParentColumnAtRootLevel() {
        let items = [TestTreeNode(name: "Item")]
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasParentHeader = pickerInput.writtenText.contains { $0.contains("PARENT") }
        let hasRootMessage = pickerInput.writtenText.contains { $0.contains("Root level") }
        #expect(hasParentHeader == false)
        #expect(hasRootMessage == false)
    }

    @Test("Renders parent and current column headers when a parent exists")
    func rendersParentAndCurrentColumnHeadersWhenParentExists() {
        let items = [TestTreeNode(name: "Root", hasChildren: true, children: [TestTreeNode(name: "Child")])]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasParentHeader = pickerInput.writtenText.contains { $0.contains("PARENT") }
        let hasCurrentHeader = pickerInput.writtenText.contains { $0.contains("CURRENT") }
        #expect(hasParentHeader)
        #expect(hasCurrentHeader)
    }

    @Test("Displays active item with highlighted marker in current column")
    func displaysActiveItemWithHighlightedMarkerInCurrentColumn() {
        let items = [TestTreeNode(name: "Active")]
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasActiveMarker = pickerInput.writtenText.contains { $0.contains("➤") }
        #expect(hasActiveMarker)
    }

    @Test("Displays item names in current column")
    func displaysItemNamesInCurrentColumn() {
        let itemName = "TestItem"
        let items = [TestTreeNode(name: itemName)]
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasItemName = pickerInput.writtenText.contains { $0.contains(itemName) }
        #expect(hasItemName)
    }

    @Test("Shows folder icon for items with children")
    func showsFolderIconForItemsWithChildren() {
        let items = [TestTreeNode(name: "Folder", hasChildren: true)]
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFolderIcon = pickerInput.writtenText.contains { $0.contains("▸") }
        #expect(hasFolderIcon)
    }

    @Test("Displays empty placeholder for column with no items")
    func displaysEmptyPlaceholderForColumnWithNoItems() {
        let items: [TestTreeNode] = []
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 0, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasEmptyMessage = pickerInput.writtenText.contains { $0.contains("empty") }
        #expect(hasEmptyMessage)
    }

    @Test("Renders multiple items in current column")
    func rendersMultipleItemsInCurrentColumn() {
        let items = [
            TestTreeNode(name: "First"),
            TestTreeNode(name: "Second"),
            TestTreeNode(name: "Third")
        ]
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 3, visibleRowCount: 15)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFirst = pickerInput.writtenText.contains { $0.contains("First") }
        let hasSecond = pickerInput.writtenText.contains { $0.contains("Second") }
        let hasThird = pickerInput.writtenText.contains { $0.contains("Third") }
        #expect(hasFirst && hasSecond && hasThird)
    }

    @Test("Uses custom icon from metadata when available")
    func usesCustomIconFromMetadataWhenAvailable() {
        let customIcon = "📁"
        let metadata = TreeNodeMetadata(icon: customIcon)
        let items = [TestTreeNode(name: "Item", metadata: metadata)]
        let state = makeState(rootItems: items)
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasCustomIcon = pickerInput.writtenText.contains { $0.contains(customIcon) }
        #expect(hasCustomIcon)
    }

    @Test("Positions columns with appropriate spacing when parent exists")
    func positionsColumnsWithAppropriateSpacingWhenParentExists() {
        let items = [TestTreeNode(name: "Root", hasChildren: true, children: [TestTreeNode(name: "Child")])]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasLeftColumnCalls = pickerInput.moveToCalls.contains { $0.col == 0 }
        let hasRightColumnCalls = pickerInput.moveToCalls.contains { $0.col > 10 }
        #expect(hasLeftColumnCalls && hasRightColumnCalls)
    }

    @Test("Renders parent column when navigated into child level")
    func rendersParentColumnWhenNavigatedIntoChildLevel() {
        let parentName = "Parent"
        let childName = "Child"
        let rootItem = TestTreeNode(name: parentName, hasChildren: true, children: [
            TestTreeNode(name: childName)
        ])
        let items = [rootItem]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 15)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasParentName = pickerInput.writtenText.contains { $0.contains(parentName) }
        let hasChildName = pickerInput.writtenText.contains { $0.contains(childName) }
        #expect(hasParentName && hasChildName)
    }
}


// MARK: - Helpers
private extension TreeNavigationRendererTests {
    func makeSUT() -> (TreeNavigationRenderer<TestTreeNode>, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = TreeNavigationRenderer<TestTreeNode>()
        return (sut, pickerInput)
    }

    func makeState(rootItems: [TestTreeNode]) -> TreeNavigationState<TestTreeNode> {
        TreeNavigationState(rootItems: rootItems, prompt: "Test")
    }

    func makeContext(startIndex: Int, endIndex: Int, listStartRow: Int = 0, visibleRowCount: Int) -> ScrollRenderContext {
        ScrollRenderContext(startIndex: startIndex, endIndex: endIndex, listStartRow: listStartRow, visibleRowCount: visibleRowCount)
    }
}


// MARK: - Test Items
private struct TestTreeNode: TreeNodePickerItem {
    let name: String
    let hasChildren: Bool
    let children: [TestTreeNode]
    let metadata: TreeNodeMetadata?
    let isSelectable: Bool

    init(name: String, hasChildren: Bool = false, children: [TestTreeNode] = [], metadata: TreeNodeMetadata? = nil, isSelectable: Bool = true) {
        self.name = name
        self.hasChildren = hasChildren
        self.children = children
        self.metadata = metadata
        self.isSelectable = isSelectable
    }

    var displayName: String { name }
    var description: String { "Description for \(name)" }

    func loadChildren() -> [TestTreeNode] {
        children
    }
}
