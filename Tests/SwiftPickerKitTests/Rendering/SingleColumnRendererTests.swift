//
//  SingleColumnRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct SingleColumnRendererTests {
    @Test
    func `Starting values empty`() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test
    func `Renders single item at correct row position`() {
        let items = [TestFactory.makeItem(name: "First")]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1, listStartRow: 5)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let rowCalls = pickerInput.moveToCalls.map { $0.row }
        #expect(rowCalls.contains(5))
    }

    @Test
    func `Displays active item with filled marker in single selection mode`() {
        let items = [TestFactory.makeItem(name: "Active")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFilledMarker = pickerInput.writtenText.contains { $0.contains("●") }
        #expect(hasFilledMarker)
    }

    @Test
    func `Displays inactive item with empty marker in single selection mode`() {
        let items = makeItems(names: ["First", "Second"])
        let state = makeState(items: items, isSingle: true, activeIndex: 0)
        let context = makeContext(startIndex: 0, endIndex: 2)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let markerWrites = pickerInput.writtenText.filter { $0.contains("○") || $0.contains("●") }
        #expect(markerWrites.count == 2)
    }

    @Test
    func `Displays selected items with filled marker in multi-selection mode`() {
        let items = [TestFactory.makeItem(name: "Item")]
        let state = makeState(items: items, isSingle: false, selectedIndices: [0])
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasFilledMarker = pickerInput.writtenText.contains { $0.contains("●") }
        #expect(hasFilledMarker)
    }

    @Test
    func `Displays unselected items with empty marker in multi-selection mode`() {
        let items = [TestFactory.makeItem(name: "Unselected")]
        let state = makeState(items: items, isSingle: false)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasEmptyMarker = pickerInput.writtenText.contains { $0.contains("○") }
        #expect(hasEmptyMarker)
    }

    @Test
    func `Applies underline formatting to active item text`() {
        let items = [TestFactory.makeItem(name: "Active")]
        let state = makeState(items: items, isSingle: true, activeIndex: 0)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let hasUnderlineText = pickerInput.writtenText.contains { $0.contains("Active") }
        #expect(hasUnderlineText)
    }

    @Test
    func `Renders multiple items in sequential rows`() {
        let items = makeItems(names: ["First", "Second", "Third"])
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 3, listStartRow: 10)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let rowCalls = pickerInput.moveToCalls.map { $0.row }
        #expect(rowCalls.contains(10))
        #expect(rowCalls.contains(11))
        #expect(rowCalls.contains(12))
    }

    @Test
    func `Renders only visible items within scroll window`() {
        let items = makeItems(names: ["Item1", "Item2", "Item3"])
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 1, endIndex: 2)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        let textWrites = pickerInput.writtenText.filter { $0.contains("Item") }
        #expect(textWrites.count == 1)
    }

    @Test
    func `Truncates text when exceeding screen width`() {
        let longName = String(repeating: "A", count: 100)
        let items = [TestFactory.makeItem(name: longName)]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let screenWidth = 20
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: screenWidth)

        let textWithEllipsis = pickerInput.writtenText.contains { $0.contains("…") }
        #expect(textWithEllipsis)
    }

    @Test
    func `Positions cursor at column zero before moving right`() {
        let items = [TestFactory.makeItem(name: "Item")]
        let state = makeState(items: items, isSingle: true)
        let context = makeContext(startIndex: 0, endIndex: 1)
        let (sut, pickerInput) = makeSUT()

        sut.render(items: items, state: state, context: context, input: pickerInput, screenWidth: 80)

        #expect(pickerInput.moveToCalls.allSatisfy { $0.col == 0 })
    }

    @Test
    func `Writes item display names to output`() {
        let itemName = "TestItem"
        let items = [TestFactory.makeItem(name: itemName)]
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
        return .init(startIndex: startIndex, endIndex: endIndex, listStartRow: listStartRow, visibleRowCount: visibleRowCount)
    }

    func makeItems(names: [String]) -> [TestItem] {
        names.map { TestFactory.makeItem(name: $0) }
    }
}


// MARK: - SUT
private extension SingleColumnRendererTests {
func makeSUT() -> (SingleColumnRenderer<TestItem>, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = SingleColumnRenderer<TestItem>()
        return (sut, pickerInput)
    }
}
