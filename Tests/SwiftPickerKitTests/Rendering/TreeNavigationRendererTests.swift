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

    @Test("Shows arrows on parent header when parent column is active")
    func showsArrowsOnParentHeaderWhenParentColumnIsActive() {
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: [
            TestTreeNode(name: "Child")
        ])
        let items = [rootItem]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()
        state.focusParentColumnIfAvailable()

        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasParentTitle = pickerInput.writtenText.contains { $0.contains("PARENT") }
        let hasLeftArrow = pickerInput.writtenText.contains { $0.contains("←") }
        let hasRightArrow = pickerInput.writtenText.contains { $0.contains("→") }
        #expect(hasParentTitle && hasLeftArrow && hasRightArrow)
    }

    @Test("Shows arrows on current header when current column is active and can navigate")
    func showsArrowsOnCurrentHeaderWhenCurrentColumnIsActiveAndCanNavigate() {
        let child = TestTreeNode(name: "Child", hasChildren: true, children: [TestTreeNode(name: "Grandchild")])
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: [child])
        let items = [rootItem]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()

        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasCurrentTitle = pickerInput.writtenText.contains { $0.contains("CURRENT") }
        let hasLeadingArrow = pickerInput.writtenText.contains { $0.contains("←") }
        let hasTrailingArrow = pickerInput.writtenText.contains { $0.contains("→") }
        #expect(hasCurrentTitle && hasLeadingArrow && hasTrailingArrow)
    }

    @Test("Shows children title when parent column is active")
    func showsChildrenTitleWhenParentColumnIsActive() {
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: [
            TestTreeNode(name: "Child")
        ])
        let items = [rootItem]
        let state = makeState(rootItems: items)
        state.descendIntoChildIfPossible()
        state.focusParentColumnIfAvailable()

        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasChildrenTitle = pickerInput.writtenText.contains { $0.contains("CHILDREN") }
        #expect(hasChildrenTitle)
    }

    @Test("Shows scroll indicators for parent column when parent items exceed visible rows")
    func showsScrollIndicatorsForParentColumnWhenParentItemsExceedVisibleRows() {
        let manyItems = (0..<20).map { TestTreeNode(name: "Item\($0)", hasChildren: true, children: [TestTreeNode(name: "Child\($0)")]) }
        let state = makeState(rootItems: manyItems)
        state.descendIntoChildIfPossible()
        state.focusParentColumnIfAvailable()

        let context = makeContext(startIndex: 0, endIndex: 5, visibleRowCount: 5)
        let (sut, pickerInput) = makeSUT(screenSize: (20, 80))

        sut.renderScrollIndicators(showUp: false, showDown: true, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: 10, totalRows: 20)

        let hasDownArrow = pickerInput.writtenText.contains { $0.contains("↓") }
        let downArrowAtLeftColumn = pickerInput.moveToCalls.contains { $0.col == 0 }
        #expect(hasDownArrow)
        #expect(downArrowAtLeftColumn)
    }

    @Test("Shows scroll up indicators for parent column when parent items exceed visible rows and scrolled")
    func showsScrollUpIndicatorsForParentColumnWhenParentItemsExceedVisibleRowsAndScrolled() {
        let manyItems = (0..<20).map { TestTreeNode(name: "Item\($0)", hasChildren: true, children: [TestTreeNode(name: "Child\($0)")]) }
        let state = makeState(rootItems: manyItems)
        state.descendIntoChildIfPossible()
        state.focusParentColumnIfAvailable()

        for _ in 0..<10 {
            state.moveSelectionDown()
        }

        let context = makeContext(startIndex: 5, endIndex: 10, visibleRowCount: 5)
        let (sut, pickerInput) = makeSUT(screenSize: (20, 80))

        sut.renderScrollIndicators(showUp: true, showDown: false, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: 10, totalRows: 20)

        let hasUpArrow = pickerInput.writtenText.contains { $0.contains("↑") }
        let upArrowAtLeftColumn = pickerInput.moveToCalls.contains { $0.col == 0 }
        #expect(hasUpArrow)
        #expect(upArrowAtLeftColumn)
    }

    @Test("Shows scroll indicators for current column when current items exceed visible rows")
    func showsScrollIndicatorsForCurrentColumnWhenCurrentItemsExceedVisibleRows() {
        let manyChildren = (0..<20).map { TestTreeNode(name: "Child\($0)") }
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: manyChildren)
        let state = makeState(rootItems: [rootItem])
        state.descendIntoChildIfPossible()

        let context = makeContext(startIndex: 0, endIndex: 5, visibleRowCount: 5)
        let (sut, pickerInput) = makeSUT(screenSize: (20, 80))

        sut.renderScrollIndicators(showUp: false, showDown: true, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: 10, totalRows: 20)

        let hasDownArrow = pickerInput.writtenText.contains { $0.contains("↓") }
        let downArrowAtRightColumn = pickerInput.moveToCalls.contains { $0.col > 10 }
        #expect(hasDownArrow)
        #expect(downArrowAtRightColumn)
    }

    @Test("Shows scroll up indicators for current column when current items exceed visible rows and scrolled")
    func showsScrollUpIndicatorsForCurrentColumnWhenCurrentItemsExceedVisibleRowsAndScrolled() {
        let manyChildren = (0..<20).map { TestTreeNode(name: "Child\($0)") }
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: manyChildren)
        let state = makeState(rootItems: [rootItem])
        state.descendIntoChildIfPossible()

        for _ in 0..<10 {
            state.moveSelectionDown()
        }

        let context = makeContext(startIndex: 5, endIndex: 10, visibleRowCount: 5)
        let (sut, pickerInput) = makeSUT(screenSize: (20, 80))

        sut.renderScrollIndicators(showUp: true, showDown: false, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: 10, totalRows: 20)

        let hasUpArrow = pickerInput.writtenText.contains { $0.contains("↑") }
        let upArrowAtRightColumn = pickerInput.moveToCalls.contains { $0.col > 10 }
        #expect(hasUpArrow)
        #expect(upArrowAtRightColumn)
    }

    @Test("Shows scroll indicators for both columns when both exceed visible rows")
    func showsScrollIndicatorsForBothColumnsWhenBothExceedVisibleRows() {
        let manyChildren = (0..<20).map { TestTreeNode(name: "Child\($0)") }
        let manyItems = (0..<20).map { index in
            TestTreeNode(name: "Item\(index)", hasChildren: true, children: index == 0 ? manyChildren : [])
        }
        let state = makeState(rootItems: manyItems)
        state.descendIntoChildIfPossible()

        let context = makeContext(startIndex: 0, endIndex: 5, visibleRowCount: 5)
        let (sut, pickerInput) = makeSUT(screenSize: (20, 80))

        sut.renderScrollIndicators(showUp: false, showDown: true, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: 10, totalRows: 20)

        let downArrowAtLeftColumn = pickerInput.moveToCalls.contains { $0.col == 0 }
        let downArrowAtRightColumn = pickerInput.moveToCalls.contains { $0.col > 10 }
        #expect(downArrowAtLeftColumn)
        #expect(downArrowAtRightColumn)
    }

    @Test("Positions scroll up arrow at correct row")
    func positionsScrollUpArrowAtCorrectRow() {
        let manyChildren = (0..<20).map { TestTreeNode(name: "Child\($0)") }
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: manyChildren)
        let state = makeState(rootItems: [rootItem])
        state.descendIntoChildIfPossible()

        for _ in 0..<10 {
            state.moveSelectionDown()
        }

        let context = makeContext(startIndex: 5, endIndex: 10, visibleRowCount: 5)
        let headerHeight = 10
        let (sut, pickerInput) = makeSUT(screenSize: (20, 80))

        sut.renderScrollIndicators(showUp: true, showDown: false, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: headerHeight, totalRows: 20)

        let expectedRow = headerHeight - 1
        let hasUpArrowAtCorrectRow = pickerInput.moveToCalls.contains { $0.row == expectedRow }
        #expect(hasUpArrowAtCorrectRow)
    }

    @Test("Positions scroll down arrow at correct row")
    func positionsScrollDownArrowAtCorrectRow() {
        let manyChildren = (0..<20).map { TestTreeNode(name: "Child\($0)") }
        let rootItem = TestTreeNode(name: "Root", hasChildren: true, children: manyChildren)
        let state = makeState(rootItems: [rootItem])
        state.descendIntoChildIfPossible()

        let context = makeContext(startIndex: 0, endIndex: 5, visibleRowCount: 5)
        let totalRows = 20
        let (sut, pickerInput) = makeSUT(screenSize: (totalRows, 80))

        sut.renderScrollIndicators(showUp: false, showDown: true, state: state, context: context, input: pickerInput, screenWidth: 80, headerHeight: 10, totalRows: totalRows)

        let footerHeight = PickerFooterRenderer(pickerInput: pickerInput).height()
        let expectedRow = totalRows - footerHeight
        let hasDownArrowAtCorrectRow = pickerInput.moveToCalls.contains { $0.row == expectedRow }
        #expect(hasDownArrowAtCorrectRow)
    }
}


// MARK: - Helpers
private extension TreeNavigationRendererTests {
    func makeSUT(screenSize: (rows: Int, cols: Int) = (40, 100)) -> (TreeNavigationRenderer<TestTreeNode>, MockPickerInput) {
        let pickerInput = MockPickerInput(screenSize: screenSize)
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
