//
//  SwiftPickerCommandLineSelectionTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineSelectionTests {
    @Test("CommandLineSelection singleSelection returns selected item")
    func singleSelectionReturnsSelectedItem() {
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

    @Test("CommandLineSelection singleSelection returns nil when quit")
    func singleSelectionReturnsNilWhenQuit() {
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

    @Test("CommandLineSelection requiredSingleSelection throws when user quits")
    func requiredSingleSelectionThrowsWhenUserQuits() {
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

    @Test("CommandLineSelection multiSelection returns selected items")
    func multiSelectionReturnsSelectedItems() {
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

    @Test("CommandLineSelection multiSelection returns empty when quit")
    func multiSelectionReturnsEmptyWhenQuit() {
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
        let textInput = SelectionTextInputStub()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        return (sut, pickerInput)
    }
}


// MARK: - Test Doubles
private final class SelectionTextInputStub: TextInput {
    func getInput(_ prompt: String) -> String {
        return ""
    }

    func getPermission(_ prompt: String) -> Bool {
        return true
    }
}
