//
//  TwoColumnDynamicDetailStateTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TwoColumnDynamicDetailStateTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let prompt = "Prompt"
        let (sut, leftState, options, detailCalls) = makeSUT(prompt: prompt)

        #expect(sut.leftState === leftState)
        #expect(sut.prompt == prompt)
        #expect(sut.activeIndex == 0)
        #expect(sut.options.count == options.count)
        #expect(sut.topLineText == leftState.topLineText)
        #expect(sut.bottomLineText == leftState.bottomLineText)
        #expect(detailCalls().isEmpty)
    }

    @Test("Shares active index with left column")
    func sharesActiveIndexWithLeftColumn() {
        let (sut, leftState, _, _) = makeSUT()

        sut.activeIndex = 1

        #expect(leftState.activeIndex == 1)
    }

    @Test("Reads active index from left column")
    func readsActiveIndexFromLeftColumn() {
        let (sut, leftState, _, _) = makeSUT()
        leftState.activeIndex = 1

        #expect(sut.activeIndex == 1)
    }

    @Test("Forwards selection toggles to left column")
    func forwardsSelectionTogglesToLeftColumn() {
        let (sut, leftState, _, _) = makeSUT(optionCount: 2)

        sut.toggleSelection(at: 1)

        #expect(leftState.options[1].isSelected)
    }

    @Test("Provides options from left column")
    func providesOptionsFromLeftColumn() {
        let (sut, leftState, _, _) = makeSUT(optionCount: 3, selectedIndices: [2])

        #expect(sut.options.count == leftState.options.count)
        #expect(sut.options[2].isSelected)
    }

    @Test("Uses left column metadata for header and footer")
    func usesLeftColumnMetadataForHeaderAndFooter() {
        let prompt = "Choose"
        let (sut, leftState, _, _) = makeSUT(prompt: prompt, isSingleSelection: false)

        #expect(sut.prompt == prompt)
        #expect(sut.topLineText == leftState.topLineText)
        #expect(sut.bottomLineText == leftState.bottomLineText)
    }

    @Test("Returns detail text from provided closure")
    func returnsDetailTextFromProvidedClosure() {
        let detailText = "Detail value"
        let (sut, _, options, detailCalls) = makeSUT(detailText: detailText)
        let item = options[0].item

        let detail = sut.detailForItem(item)

        #expect(detail == detailText)
        #expect(detailCalls().contains { $0.displayName == item.displayName })
    }
}


// MARK: - SUT
private extension TwoColumnDynamicDetailStateTests {
    func makeSUT(optionCount: Int = 1, selectedIndices: Set<Int> = [], prompt: String = "Prompt", isSingleSelection: Bool = true, detailText: String = "Detail", fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (TwoColumnDynamicDetailState<TestItem>, SelectionState<TestItem>, [Option<TestItem>], () -> [TestItem]) {
        let options = TestFactory.makeOptions(count: optionCount, selectedIndices: selectedIndices)
        let left = SelectionState(options: options, prompt: prompt, isSingleSelection: isSingleSelection)
        let recorder = makeDetailRecorder(text: detailText)
        let sut = TwoColumnDynamicDetailState(leftState: left, detailForItem: recorder.closure)
        return (sut, left, options, recorder.calls)
    }

    func makeDetailRecorder(text: String) -> (closure: (TestItem) -> String, calls: () -> [TestItem]) {
        var captured: [TestItem] = []
        let closure: (TestItem) -> String = { item in
            captured.append(item)
            return text
        }
        return (closure, { captured })
    }
}
