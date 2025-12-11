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

    @Test("Selects leaf nodes")
    func selectsLeafNodes() {
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

    @Test("Always starts inside first root when available")
    func alwaysStartsInsideFirstRootWhenAvailable() {
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

    @Test("Returns nil when user quits navigation")
    func returnsNilWhenUserQuitsNavigation() {
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

    @Test("Throws when required navigation is cancelled")
    func throwsWhenRequiredNavigationIsCancelled() {
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


// MARK: - SUT
private extension SwiftPickerCommandLineTreeNavigationTests {
    func makeRoot(from item: TreeTestItem) -> TreeNavigationRoot<TreeTestItem> {
        if !item.children.isEmpty {
            return TreeNavigationRoot(displayName: item.displayName, children: item.children)
        }
        return TreeNavigationRoot(displayName: item.displayName, children: [item])
    }

    func makeSUT() -> (any CommandLineTreeNavigation, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        
        return (sut, pickerInput)
    }
}
