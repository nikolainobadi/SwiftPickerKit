//
//  SelectionStateTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct SelectionStateTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let prompt = "Prompt"
        let (sut, options) = makeSUT(optionCount: 2, isSingleSelection: true, prompt: prompt)

        #expect(sut.prompt == prompt)
        #expect(sut.isSingleSelection)
        #expect(sut.options.count == options.count)
        #expect(sut.options.allSatisfy { !$0.isSelected })
        #expect(sut.activeIndex == 0)
        #expect(sut.selectedItemForHeader == nil)
        #expect(sut.isShowingScrollUpIndicator == false)
    }

    @Test("Shows single selection mode in header")
    func showsSingleSelectionModeInHeader() {
        let (sut, _) = makeSUT(isSingleSelection: true)

        #expect(sut.topLineText == "InteractivePicker (single-selection)")
    }

    @Test("Shows multi selection mode in header")
    func showsMultiSelectionModeInHeader() {
        let (sut, _) = makeSUT(isSingleSelection: false)

        #expect(sut.topLineText == "InteractivePicker (multi-selection)")
    }

    @Test("Guides single selection completion")
    func guidesSingleSelectionCompletion() {
        let (sut, _) = makeSUT(isSingleSelection: true)

        #expect(sut.bottomLineText == "Tap 'enter' to select. Type 'q' to quit.")
    }

    @Test("Guides multi selection completion")
    func guidesMultiSelectionCompletion() {
        let (sut, _) = makeSUT(isSingleSelection: false)

        #expect(sut.bottomLineText == "Select multiple items with 'spacebar'. Tap 'enter' to finish.")
    }

    @Test("Toggles option selection within bounds")
    func togglesOptionSelectionWithinBounds() {
        let (sut, _) = makeSUT(optionCount: 2, isSingleSelection: true)

        sut.toggleSelection(at: 1)
        #expect(sut.options[1].isSelected)

        sut.toggleSelection(at: 1)
        #expect(sut.options[1].isSelected == false)
    }

    @Test("Ignores selection changes outside option range")
    func ignoresSelectionChangesOutsideOptionRange() {
        let (sut, _) = makeSUT(optionCount: 1, isSingleSelection: false)
        let initialSelectionStates = sut.options.map(\.isSelected)

        sut.toggleSelection(at: 2)

        #expect(sut.options.map(\.isSelected) == initialSelectionStates)
    }

    @Test("Returns only chosen options")
    func returnsOnlyChosenOptions() {
        let selectedIndices: Set<Int> = [0, 2]
        let (sut, _) = makeSUT(optionCount: 3, isSingleSelection: false, selectedIndices: selectedIndices)
        let expectedNames = TestFactory.makeOptions(count: 3, selectedIndices: selectedIndices).filter(\.isSelected).map { $0.title }

        let selectedNames = sut.selectedOptions.map { $0.title }

        #expect(selectedNames.count == expectedNames.count)
        #expect(Set(selectedNames) == Set(expectedNames))
    }

    @Test("Hides selection markers in single mode")
    func hidesSelectionMarkersInSingleMode() {
        let (sut, _) = makeSUT(optionCount: 1, isSingleSelection: true, selectedIndices: [0])
        let option = sut.options[0]

        #expect(sut.showAsSelected(option) == false)
    }

    @Test("Reflects selection state in multi mode")
    func reflectsSelectionStateInMultiMode() {
        let (sut, _) = makeSUT(optionCount: 2, isSingleSelection: false, selectedIndices: [1])
        let selectedOption = sut.options[1]
        let unselectedOption = sut.options[0]

        #expect(sut.showAsSelected(selectedOption))
        #expect(sut.showAsSelected(unselectedOption) == false)
    }
}


// MARK: - SUT
private extension SelectionStateTests {
    func makeSUT(optionCount: Int = 1, isSingleSelection: Bool = true, selectedIndices: Set<Int> = [], prompt: String = "Prompt", activeIndex: Int = 0, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (SelectionState<TestItem>, [Option<TestItem>]) {
        let options = TestFactory.makeOptions(count: optionCount, selectedIndices: selectedIndices)
        let sut = SelectionState(options: options, prompt: prompt, isSingleSelection: isSingleSelection)
        sut.activeIndex = activeIndex
        return (sut, options)
    }
}
