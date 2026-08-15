//
//  TwoColumnStateTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TwoColumnStateTests {
    @Test
    func `Starting values empty`() {
        let prompt = "Prompt"
        let rightItems = TestFactory.makeRightItems(count: 2)
        let (sut, leftState, initialOptions) = makeSUT(prompt: prompt, rightItems: rightItems)

        #expect(sut.leftState === leftState)
        #expect(sut.prompt == prompt)
        #expect(sut.activeIndex == 0)
        #expect(sut.options.count == initialOptions.count)
        #expect(sut.options.allSatisfy { $0.isSelected == false })
        #expect(sut.topLineText == leftState.topLineText)
        #expect(sut.bottomLineText == leftState.bottomLineText)
        #expect(sut.rightItems.map(\.displayName) == rightItems.map(\.displayName))
    }

    @Test
    func `Shares active index with left column`() {
        let (sut, leftState, _) = makeSUT()

        sut.activeIndex = 1

        #expect(leftState.activeIndex == 1)
    }

    @Test
    func `Reads active index from left column`() {
        let (sut, leftState, _) = makeSUT()
        leftState.activeIndex = 1

        #expect(sut.activeIndex == 1)
    }

    @Test
    func `Forwards selection toggles to left column`() {
        let (sut, leftState, _) = makeSUT(optionCount: 2)

        sut.toggleSelection(at: 1)

        #expect(leftState.options[1].isSelected)
    }

    @Test
    func `Provides options from left column`() {
        let (sut, leftState, _) = makeSUT(optionCount: 3, selectedIndices: [1])

        #expect(sut.options.count == leftState.options.count)
        #expect(sut.options[1].isSelected)
    }

    @Test
    func `Uses left column metadata for header and footer`() {
        let prompt = "Choose"
        let (sut, leftState, _) = makeSUT(prompt: prompt, isSingleSelection: false)

        #expect(sut.prompt == prompt)
        #expect(sut.topLineText == leftState.topLineText)
        #expect(sut.bottomLineText == leftState.bottomLineText)
    }
}


// MARK: - Helpers
private extension TwoColumnStateTests {

}


// MARK: - Test Factory Helpers
private extension TestFactory {
    static func makeRightItems(count: Int) -> [TestItem] {
        (0..<count).map { index in
            makeItem(name: "Right \(index)")
        }
    }
}


// MARK: - SUT
private extension TwoColumnStateTests {
func makeSUT(optionCount: Int = 1, selectedIndices: Set<Int> = [], prompt: String = "Prompt", isSingleSelection: Bool = true, rightItems: [TestItem] = TestFactory.makeRightItems(count: 1)) -> (TwoColumnState<TestItem>, SelectionState<TestItem>, [Option<TestItem>]) {
        let options = TestFactory.makeOptions(count: optionCount, selectedIndices: selectedIndices)
        let leftState = SelectionState(options: options, prompt: prompt, isSingleSelection: isSingleSelection)
        let sut = TwoColumnState(leftState: leftState, rightItems: rightItems)
        return (sut, leftState, options)
    }
}
