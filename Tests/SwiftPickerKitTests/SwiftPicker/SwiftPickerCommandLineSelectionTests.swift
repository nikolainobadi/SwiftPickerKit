//
//  SwiftPickerCommandLineSelectionTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineSelectionTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test("Returns selected item when user confirms choice")
    func returnsSelectedItemWhenUserConfirmsChoice() {
        let items = ["First", "Second"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = selection.singleSelection(
            prompt: "Pick one",
            items: items,
            layout: .singleColumn,
            newScreen: false
        )

        #expect(result == items[0])
    }

    @Test("Returns nil when user quits selection")
    func returnsNilWhenUserQuitsSelection() {
        let items = ["Alpha", "Beta"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        let result = selection.singleSelection(
            prompt: "Pick one",
            items: items,
            layout: .singleColumn,
            newScreen: false
        )

        #expect(result == nil)
    }

    @Test("Throws error when user quits required selection")
    func throwsErrorWhenUserQuitsRequiredSelection() {
        let items = ["Red", "Blue"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        #expect(throws: SwiftPickerError.self) {
            _ = try selection.requiredSingleSelection(
                prompt: "Pick color",
                items: items,
                layout: .singleColumn,
                newScreen: false
            )
        }
    }

    @Test("Returns multiple selected items when confirmed")
    func returnsMultipleSelectedItemsWhenConfirmed() {
        let items = ["One", "Two", "Three"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.space)
        pickerInput.enqueueDirectionKey(.down)
        pickerInput.enqueueSpecialChar(.space)
        pickerInput.enqueueSpecialChar(.enter)

        let result = selection.multiSelection(
            prompt: "Pick many",
            items: items,
            layout: .singleColumn,
            newScreen: false
        )

        #expect(result.count == 2)
        #expect(result.contains(items[0]))
        #expect(result.contains(items[1]))
    }

    @Test("Returns empty array when user quits multi-selection")
    func returnsEmptyArrayWhenUserQuitsMultiSelection() {
        let items = ["Spring", "Summer"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        let result = selection.multiSelection(
            prompt: "Pick seasons",
            items: items,
            layout: .singleColumn,
            newScreen: false
        )

        #expect(result.isEmpty)
    }
}


// MARK: - Helpers
private extension SwiftPickerCommandLineSelectionTests {
    func makeSUT() -> (SwiftPicker, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        return (sut, pickerInput)
    }
}
