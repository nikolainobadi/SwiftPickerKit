//
//  SwiftPickerCommandLineTreeNavigationTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLineTreeNavigationTests {
    @Test
    func `Starting values empty`() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test
    func `Selects selectable folder`() {
        let child = TestFactory.makeTreeItem(name: "Child")
        let root = TestFactory.makeTreeItem(name: "Root", children: [child])
        let (sut, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = sut.treeNavigation(
            prompt: "Pick",
            root: makeRoot(from: root),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result?.displayName == child.displayName)
    }

    @Test
    func `Selects leaf nodes`() {
        let child = TestFactory.makeTreeItem(name: "Child")
        let root = TestFactory.makeTreeItem(name: "Root", children: [child])
        let (sut, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = sut.treeNavigation(
            prompt: "Pick leaf",
            root: makeRoot(from: root),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result?.displayName == child.displayName)
    }

    @Test
    func `Always starts inside first root when available`() {
        let child = TestFactory.makeTreeItem(name: "Child")
        let root = TestFactory.makeTreeItem(name: "Root", children: [child])
        let (sut, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.enter)

        let result = sut.treeNavigation(
            prompt: "Pick",
            root: makeRoot(from: root),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result?.displayName == child.displayName)
    }

    @Test
    func `Returns nil when user quits navigation`() {
        let root = TestFactory.makeTreeItem(name: "Root")
        let (sut, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        let result = sut.treeNavigation(
            prompt: "Quit",
            root: makeRoot(from: root),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result == nil)
    }

    @Test
    func `Throws when required navigation is cancelled`() {
        let root = TestFactory.makeTreeItem(name: "Root")
        let (sut, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(.quit)

        #expect(throws: SwiftPickerError.self) {
            _ = try sut.requiredTreeNavigation(
                prompt: "Quit",
                root: makeRoot(from: root),
                showPromptText: true,
                showSelectedItemText: true
            )
        }
    }
}


// MARK: - Helpers
private extension SwiftPickerCommandLineTreeNavigationTests {
    func makeRoot(from item: TreeTestItem) -> TreeNavigationRoot<TreeTestItem> {
        if !item.children.isEmpty {
            return TreeNavigationRoot(displayName: item.displayName, children: item.children)
        }
        return TreeNavigationRoot(displayName: item.displayName, children: [item])
    }
}


// MARK: - SUT
private extension SwiftPickerCommandLineTreeNavigationTests {
func makeSUT() -> (any CommandLineTreeNavigation, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        
        return (sut, pickerInput)
    }
}
