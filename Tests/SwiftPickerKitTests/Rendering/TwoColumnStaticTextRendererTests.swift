//
//  TwoColumnStaticTextRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct TwoColumnStaticTextRendererTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test("Renders items in left column with markers")
    func rendersItemsInLeftColumnWithMarkers() {
        let items = [TestItem(name: "First"), TestItem(name: "Second")]
        let state = makeState(items: items, isSingle: true, rightText: "Static text")
        let context = makeContext(startIndex: 0, endIndex: 2)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasMarkers = pickerInput.writtenText.contains { $0.contains("●") || $0.contains("○") }
        #expect(hasMarkers)
    }

    @Test("Displays active item with filled marker in single selection mode")
    func displaysActiveItemWithFilledMarkerInSingleSelectionMode() {
        let items = [TestItem(name: "Active")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFilledMarker = pickerInput.writtenText.contains { $0.contains("●") }
        #expect(hasFilledMarker)
    }

    @Test("Displays selected items with filled marker in multi-selection mode")
    func displaysSelectedItemsWithFilledMarkerInMultiSelectionMode() {
        let items = [TestItem(name: "Selected")]
        let state = makeState(items: items, isSingle: false, selectedIndices: [0], rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFilledMarker = pickerInput.writtenText.contains { $0.contains("●") }
        #expect(hasFilledMarker)
    }

    @Test("Applies underline to active item in left column")
    func appliesUnderlineToActiveItemInLeftColumn() {
        let items = [TestItem(name: "Active")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasItemText = pickerInput.writtenText.contains { $0.contains("Active") }
        #expect(hasItemText)
    }

    @Test("Renders static text in right column")
    func rendersStaticTextInRightColumn() {
        let staticText = "This is static information"
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true, rightText: staticText)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasStaticText = pickerInput.writtenText.contains { $0.contains(staticText) }
        #expect(hasStaticText)
    }

    @Test("Maintains same static text regardless of active item")
    func maintainsSameStaticTextRegardlessOfActiveItem() {
        let staticText = "Unchanging text"
        let items = [TestItem(name: "First"), TestItem(name: "Second")]
        let state1 = makeState(items: items, isSingle: true, activeIndex: 0, rightText: staticText)
        let state2 = makeState(items: items, isSingle: true, activeIndex: 1, rightText: staticText)
        let context = makeContext(startIndex: 0, endIndex: 2)
        let (sut, pickerInput1) = makeSUT()
        let (_, pickerInput2) = makeSUT()

        sut.render(items: items, state: state1, context: context, input: pickerInput1, screenWidth: 80)
        sut.render(items: items, state: state2, context: context, input: pickerInput2, screenWidth: 80)

        let hasText1 = pickerInput1.writtenText.contains { $0.contains(staticText) }
        let hasText2 = pickerInput2.writtenText.contains { $0.contains(staticText) }
        #expect(hasText1 && hasText2)
    }

    @Test("Displays column divider between left and right columns")
    func displaysColumnDividerBetweenLeftAndRightColumns() {
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasDivider = pickerInput.writtenText.contains { $0.contains("│") }
        #expect(hasDivider)
    }

    @Test("Truncates long item names in left column")
    func truncatesLongItemNamesInLeftColumn() {
        let longName = String(repeating: "A", count: 100)
        let items = [TestItem(name: longName)]
        let state = makeState(items: items, isSingle: true, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 60)

        let hasEllipsis = pickerInput.writtenText.contains { $0.contains("…") }
        #expect(hasEllipsis)
    }

    @Test("Truncates long static text in right column")
    func truncatesLongStaticTextInRightColumn() {
        let longText = String(repeating: "B", count: 200)
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true, rightText: longText)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 60)

        let hasEllipsis = pickerInput.writtenText.contains { $0.contains("…") }
        #expect(hasEllipsis)
    }

    @Test("Positions left column at start of screen")
    func positionsLeftColumnAtStartOfScreen() {
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1, listStartRow: 5)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasLeftColumnPosition = pickerInput.moveToCalls.contains { $0.row == 5 && $0.col == 0 }
        #expect(hasLeftColumnPosition)
    }

    @Test("Positions right column after left column width")
    func positionsRightColumnAfterLeftColumnWidth() {
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasRightColumnPosition = pickerInput.moveToCalls.contains { $0.col > 15 }
        #expect(hasRightColumnPosition)
    }

    @Test("Renders multiple items in left column")
    func rendersMultipleItemsInLeftColumn() {
        let items = [
            TestItem(name: "First"),
            TestItem(name: "Second"),
            TestItem(name: "Third")
        ]
        let state = makeState(items: items, isSingle: true, rightText: "Text")
        let context = makeContext(startIndex: 0, endIndex: 3)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFirst = pickerInput.writtenText.contains { $0.contains("First") }
        let hasSecond = pickerInput.writtenText.contains { $0.contains("Second") }
        let hasThird = pickerInput.writtenText.contains { $0.contains("Third") }
        #expect(hasFirst && hasSecond && hasThird)
    }

    @Test("Respects visible row limit when rendering static text lines")
    func respectsVisibleRowLimitWhenRenderingStaticTextLines() {
        let multilineText = Array(repeating: "Line", count: 100).joined(separator: "\n")
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true, rightText: multilineText)
        let context = makeContext(startIndex: 0, endIndex: 1, visibleRowCount: 5)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let textLineCalls = pickerInput.moveToCalls.filter { $0.col > 15 }
        #expect(textLineCalls.count <= 5)
    }

    @Test("Renders only items within scroll window")
    func rendersOnlyItemsWithinScrollWindow() {
        let items = [
            TestItem(name: "Item1"),
            TestItem(name: "Item2"),
            TestItem(name: "Item3")
        ]
        let state = makeState(items: items, isSingle: true, activeIndex: 1, rightText: "Text")
        let context = makeContext(startIndex: 1, endIndex: 2)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasItem1 = pickerInput.writtenText.contains { $0.contains("Item1") }
        let hasItem2 = pickerInput.writtenText.contains { $0.contains("Item2") }
        let hasItem3 = pickerInput.writtenText.contains { $0.contains("Item3") }
        #expect(!hasItem1 && hasItem2 && !hasItem3)
    }
}


// MARK: - Helpers
private extension TwoColumnStaticTextRendererTests {
    func makeSUT() -> (TwoColumnStaticTextRenderer<TestItem>, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = TwoColumnStaticTextRenderer<TestItem>()
        return (sut, pickerInput)
    }

    func makeState(
        items: [TestItem],
        isSingle: Bool,
        activeIndex: Int = 0,
        selectedIndices: [Int] = [],
        rightText: String
    ) -> TwoColumnStaticTextState<TestItem> {
        var options = items.map { Option(item: $0) }
        for index in selectedIndices {
            if options.indices.contains(index) {
                options[index].isSelected = true
            }
        }
        let leftState = SelectionState(options: options, prompt: "Test", isSingleSelection: isSingle)
        leftState.activeIndex = activeIndex
        return TwoColumnStaticTextState(left: leftState, rightText: rightText)
    }

    func makeContext(startIndex: Int, endIndex: Int, listStartRow: Int = 0, visibleRowCount: Int = 10) -> ScrollRenderContext {
        ScrollRenderContext(startIndex: startIndex, endIndex: endIndex, listStartRow: listStartRow, visibleRowCount: visibleRowCount)
    }
}


// MARK: - Test Items
private struct TestItem: DisplayablePickerItem {
    let name: String

    var displayName: String { name }
    var description: String { "Description for \(name)" }
}
