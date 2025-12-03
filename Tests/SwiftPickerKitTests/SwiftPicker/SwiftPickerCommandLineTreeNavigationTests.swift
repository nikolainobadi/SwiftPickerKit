//
//  SwiftPickerCommandLineTreeNavigationTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineTreeNavigationTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test("Selects selectable folder")
    func selectsSelectableFolder() {
        let child = TestFactory.makeTreeItem(name: "Child")
        let root = TestFactory.makeTreeItem(name: "Root", children: [child])
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineTreeNavigation = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = selection.treeNavigation(
            prompt: "Pick",
            rootItems: [root],
            newScreen: false
        )

        #expect(result?.displayName == child.displayName)
    }

    @Test("Selects leaf nodes")
    func selectsLeafNodes() {
        let child = TestFactory.makeTreeItem(name: "Child")
        let root = TestFactory.makeTreeItem(name: "Root", children: [child])
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineTreeNavigation = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = selection.treeNavigation(
            prompt: "Pick leaf",
            rootItems: [root],
            newScreen: false
        )

        #expect(result?.displayName == child.displayName)
    }

    @Test("Always starts inside first root when available")
    func alwaysStartsInsideFirstRootWhenAvailable() {
        let child = TestFactory.makeTreeItem(name: "Child")
        let root = TestFactory.makeTreeItem(name: "Root", children: [child])
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineTreeNavigation = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = selection.treeNavigation(
            prompt: "Pick",
            rootItems: [root],
            newScreen: false
        )

        #expect(result?.displayName == child.displayName)
    }

    @Test("Returns nil when user quits navigation")
    func returnsNilWhenUserQuitsNavigation() {
        let root = TestFactory.makeTreeItem(name: "Root")
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineTreeNavigation = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        let result = selection.treeNavigation(
            prompt: "Quit",
            rootItems: [root],
            newScreen: false
        )

        #expect(result == nil)
    }

    @Test("Throws when required navigation is cancelled")
    func throwsWhenRequiredNavigationIsCancelled() {
        let root = TestFactory.makeTreeItem(name: "Root")
        let (sut, pickerInput) = makeSUT()
        let selection: CommandLineTreeNavigation = sut

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        #expect(throws: SwiftPickerError.self) {
            _ = try selection.requiredTreeNavigation(
                prompt: "Quit",
                rootItems: [root],
                newScreen: false
            )
        }
    }
}


// MARK: - SUT
private extension SwiftPickerCommandLineTreeNavigationTests {
    func makeSUT() -> (SwiftPicker, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        return (sut, pickerInput)
    }
}
