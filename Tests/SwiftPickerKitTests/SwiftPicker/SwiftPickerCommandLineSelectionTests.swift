//
//  SwiftPickerCommandLineSelectionTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineSelectionTests {
    @Test
    func `Starting values empty`() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test
    func `Returns selected item when user confirms choice`() {
        let items = ["First", "Second"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = selection.singleSelection(
            prompt: "Pick one",
            items: items,
            layout: .singleColumn,
            newScreen: false,
            showSelectedItemText: true
        )

        #expect(result == items[0])
    }

    @Test
    func `Returns nil when user quits selection`() {
        let items = ["Alpha", "Beta"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        let result = selection.singleSelection(
            prompt: "Pick one",
            items: items,
            layout: .singleColumn,
            newScreen: false,
            showSelectedItemText: true
        )

        #expect(result == nil)
    }

    @Test
    func `Throws error when user quits required selection`() {
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
                newScreen: false,
                showSelectedItemText: true
            )
        }
    }

    @Test
    func `Returns multiple selected items when confirmed`() {
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
            newScreen: false,
            showSelectedItemText: true
        )

        #expect(result.count == 2)
        #expect(result.contains(items[0]))
        #expect(result.contains(items[1]))
    }

    @Test
    func `Returns empty array when user quits multi-selection`() {
        let items = ["Spring", "Summer"]
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineSelection = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        let result = selection.multiSelection(
            prompt: "Pick seasons",
            items: items,
            layout: .singleColumn,
            newScreen: false,
            showSelectedItemText: true
        )

        #expect(result.isEmpty)
    }
}


// MARK: - SUT
private extension SwiftPickerCommandLineSelectionTests {
    func makeSUT() -> (SwiftPicker, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        return (sut, pickerInput)
    }
}
