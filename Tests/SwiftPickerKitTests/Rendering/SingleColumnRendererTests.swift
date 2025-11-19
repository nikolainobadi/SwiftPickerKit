//
//  SingleColumnRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct SingleColumnRendererTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test("Renders single item at correct row position")
    func rendersSingleItemAtCorrectRowPosition() {
        let items = [TestItem(name: "First")]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1, listStartRow: 5)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let rowCalls = pickerInput.moveToCalls.map { $0.row }
        #expect(rowCalls.contains(5))
    }

    @Test("Displays active item with filled marker in single selection mode")
    func displaysActiveItemWithFilledMarkerInSingleSelectionMode() {
        let items = [TestItem(name: "Active")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFilledMarker = pickerInput.writtenText.contains { $0.contains("●") }
        #expect(hasFilledMarker)
    }

    @Test("Displays inactive item with empty marker in single selection mode")
    func displaysInactiveItemWithEmptyMarkerInSingleSelectionMode() {
        let items = [TestItem(name: "First"), TestItem(name: "Second")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0)
        let context = makeContext(startIndex: 0, endIndex: 2)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let markerWrites = pickerInput.writtenText.filter { $0.contains("○") || $0.contains("●") }
        #expect(markerWrites.count == 2)
    }

    @Test("Displays selected items with filled marker in multi-selection mode")
    func displaysSelectedItemsWithFilledMarkerInMultiSelectionMode() {
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: false, selectedIndices: [0])
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFilledMarker = pickerInput.writtenText.contains { $0.contains("●") }
        #expect(hasFilledMarker)
    }

    @Test("Displays unselected items with empty marker in multi-selection mode")
    func displaysUnselectedItemsWithEmptyMarkerInMultiSelectionMode() {
        let items = [TestItem(name: "Unselected")]
        let state = makeState(items: items, isSingle: false)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasEmptyMarker = pickerInput.writtenText.contains { $0.contains("○") }
        #expect(hasEmptyMarker)
    }

    @Test("Applies underline formatting to active item text")
    func appliesUnderlineFormattingToActiveItemText() {
        let items = [TestItem(name: "Active")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasUnderlineText = pickerInput.writtenText.contains { $0.contains("Active") }
        #expect(hasUnderlineText)
    }

    @Test("Renders multiple items in sequential rows")
    func rendersMultipleItemsInSequentialRows() {
        let items = [TestItem(name: "First"), TestItem(name: "Second"), TestItem(name: "Third")]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 3, listStartRow: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let rowCalls = pickerInput.moveToCalls.map { $0.row }
        #expect(rowCalls.contains(10))
        #expect(rowCalls.contains(11))
        #expect(rowCalls.contains(12))
    }

    @Test("Renders only visible items within scroll window")
    func rendersOnlyVisibleItemsWithinScrollWindow() {
        let items = [TestItem(name: "Item1"), TestItem(name: "Item2"), TestItem(name: "Item3")]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 1, endIndex: 2)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let textWrites = pickerInput.writtenText.filter { $0.contains("Item") }
        #expect(textWrites.count == 1)
    }

    @Test("Truncates text when exceeding screen width")
    func truncatesTextWhenExceedingScreenWidth() {
        let longName = String(repeating: "A", count: 100)
        let items = [TestItem(name: longName)]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let screenWidth = 20
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: screenWidth)

        let textWithEllipsis = pickerInput.writtenText.contains { $0.contains("…") }
        #expect(textWithEllipsis)
    }

    @Test("Positions cursor at column zero before moving right")
    func positionsCursorAtColumnZeroBeforeMovingRight() {
        let items = [TestItem(name: "Item")]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        #expect(pickerInput.moveToCalls.allSatisfy { $0.col == 0 })
    }

    @Test("Writes item display names to output")
    func writesItemDisplayNamesToOutput() {
        let itemName = "TestItem"
        let items = [TestItem(name: itemName)]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasItemName = pickerInput.writtenText.contains { $0.contains(itemName) }
        #expect(hasItemName)
    }
}


// MARK: - Helpers
private extension SingleColumnRendererTests {
    func makeSUT() -> (SingleColumnRenderer<TestItem>, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = SingleColumnRenderer<TestItem>()
        return (sut, pickerInput)
    }

    func makeState(items: [TestItem], isSingle: Bool, activeIndex: Int = 0, selectedIndices: [Int] = []) -> SelectionState<TestItem> {
        var options = items.map { Option(item: $0) }
        for index in selectedIndices {
            if options.indices.contains(index) {
                options[index].isSelected = true
            }
        }
        let state = SelectionState(options: options, prompt: "Test", isSingleSelection: isSingle)
        state.activeIndex = activeIndex
        return state
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
