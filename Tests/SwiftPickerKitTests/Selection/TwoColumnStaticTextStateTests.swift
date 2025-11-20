//
//  TwoColumnStaticTextStateTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TwoColumnStaticTextStateTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let prompt = "Prompt"
        let rightText = "Right column text"
        let (sut, leftState, options) = makeSUT(prompt: prompt, rightText: rightText)

        #expect(sut.leftState === leftState)
        #expect(sut.prompt == prompt)
        #expect(sut.activeIndex == 0)
        #expect(sut.options.count == options.count)
        #expect(sut.topLineText == leftState.topLineText)
        #expect(sut.bottomLineText == leftState.bottomLineText)
        #expect(sut.wrappedRightLines(width: 20) == rightText.wrapToWidth(maxWidth: 20))
    }

    @Test("Shares active index with left column")
    func sharesActiveIndexWithLeftColumn() {
        let (sut, leftState, _) = makeSUT()

        sut.activeIndex = 1

        #expect(leftState.activeIndex == 1)
    }

    @Test("Reads active index from left column")
    func readsActiveIndexFromLeftColumn() {
        let (sut, leftState, _) = makeSUT()
        leftState.activeIndex = 1

        #expect(sut.activeIndex == 1)
    }

    @Test("Forwards selection toggles to left column")
    func forwardsSelectionTogglesToLeftColumn() {
        let (sut, leftState, _) = makeSUT(optionCount: 2)

        sut.toggleSelection(at: 1)

        #expect(leftState.options[1].isSelected)
    }

    @Test("Provides options from left column")
    func providesOptionsFromLeftColumn() {
        let (sut, leftState, _) = makeSUT(optionCount: 3, selectedIndices: [2])

        #expect(sut.options.count == leftState.options.count)
        #expect(sut.options[2].isSelected)
    }

    @Test("Wraps right column text to requested width")
    func wrapsRightColumnTextToRequestedWidth() {
        let rightText = "This is a longer line of text that should wrap across columns."
        let width = 15
        let (sut, _, _) = makeSUT(rightText: rightText)

        let wrapped = sut.wrappedRightLines(width: width)

        #expect(wrapped == rightText.wrapToWidth(maxWidth: width))
        #expect(wrapped.allSatisfy { $0.count <= width })
    }
}


// MARK: - SUT
private extension TwoColumnStaticTextStateTests {
    func makeSUT(optionCount: Int = 1, selectedIndices: Set<Int> = [], prompt: String = "Prompt", isSingleSelection: Bool = true, rightText: String = "Right text") -> (TwoColumnStaticTextState<TestItem>, SelectionState<TestItem>, [Option<TestItem>]) {
        let options = TestFactory.makeOptions(count: optionCount, selectedIndices: selectedIndices)
        let left = SelectionState(options: options, prompt: prompt, isSingleSelection: isSingleSelection)
        let sut = TwoColumnStaticTextState(leftState: left, rightText: rightText)
        return (sut, left, options)
    }
}
