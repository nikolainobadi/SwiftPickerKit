//
//  NonInteractivePickerTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Testing
@testable import SwiftPickerKit
import Foundation

struct NonInteractivePickerTests {
    @Test
    func `Text prompts resolve to an empty value`() {
        let sut = makeSUT()

        #expect(sut.getInput(prompt: "Project name").isEmpty)
    }

    @Test
    func `Permission is denied when consent is not assumed`() {
        let sut = makeSUT()

        #expect(!sut.getPermission(prompt: "Continue?"))
    }

    @Test
    func `Permission is granted when consent is assumed`() {
        let sut = makeSUT(assumeYes: true)

        #expect(sut.getPermission(prompt: "Continue?"))
    }

    @Test
    func `Choosing a single item resolves to nothing`() {
        let sut = makeSUT()

        #expect(sut.singleSelection(prompt: "Choose a project", items: makeItems()) == nil)
    }

    @Test
    func `Choosing several items resolves to nothing`() {
        let sut = makeSUT()

        #expect(sut.multiSelection(prompt: "Choose targets", items: makeItems()).isEmpty)
    }

    @Test
    func `Navigating a tree resolves to nothing`() {
        let sut = makeSUT()

        #expect(sut.treeNavigation(prompt: "Browse", root: makeTreeRoot(), showPromptText: true, showSelectedItemText: true) == nil)
    }

    @Test
    func `Browsing directories resolves to nothing`() {
        let sut = makeSUT()

        #expect(sut.browseDirectories(prompt: "Browse", startURL: makeDirectoryURL()) == nil)
    }

    @Test
    func `Browsing directories resolves to nothing when the picker is held as a protocol type`() {
        let originalSelectionType = FileSystemNode.selectionType
        defer { FileSystemNode.selectionType = originalSelectionType }
        let sut: any CommandLinePicker = makeSUT()

        #expect(sut.browseDirectories(prompt: "Browse", startURL: makeDirectoryURL()) == nil)
    }
}


// MARK: - Required Values
extension NonInteractivePickerTests {
    @Test
    func `A required value fails when none can be provided`() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.inputRequired) {
            _ = try sut.getRequiredInput(prompt: "Project name")
        }
    }

    @Test
    func `A required confirmation fails when consent is not assumed`() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.requiredPermission(prompt: "Delete builds?")
        }
    }

    @Test
    func `A required confirmation succeeds when consent is assumed`() {
        let sut = makeSUT(assumeYes: true)

        #expect(throws: Never.self) {
            try sut.requiredPermission(prompt: "Delete builds?")
        }
    }

    @Test
    func `A required single choice fails when nothing can be chosen`() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.selectionCancelled) {
            _ = try sut.requiredSingleSelection("Choose a project", items: makeItems())
        }
    }

    @Test
    func `A required tree choice fails when nothing can be chosen`() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.selectionCancelled) {
            _ = try sut.requiredTreeNavigation(prompt: "Browse", root: makeTreeRoot())
        }
    }
}


// MARK: - Named Flags
extension NonInteractivePickerTests {
    @Test
    func `A required value reports the flag that supplies it`() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.getRequiredInput(prompt: "Project name", flagHint: "--name") }

        #expect(error?.localizedDescription == "Missing required value for \"Project name\". Pass --name.")
    }

    @Test
    func `A required confirmation reports the flag that grants it`() {
        let sut = makeSUT()
        let error = captureError { try sut.requiredPermission(prompt: "Delete builds?", flagHint: "--force") }

        #expect(error?.localizedDescription == "Confirmation required for \"Delete builds?\". Pass --force.")
    }

    @Test
    func `A required confirmation succeeds when consent is assumed and a flag is named`() {
        let sut = makeSUT(assumeYes: true)

        #expect(throws: Never.self) {
            try sut.requiredPermission(prompt: "Delete builds?", flagHint: "--force")
        }
    }

    @Test
    func `A required single choice reports the flag that supplies it`() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredSingleSelection(prompt: "Choose a project", items: makeItems(), flagHint: "--project") }

        #expect(error?.localizedDescription == "No selection made for \"Choose a project\". Pass --project.")
    }

    @Test
    func `A required set of choices reports the flag that supplies them`() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredMultiSelection(prompt: "Choose targets", items: makeItems(), flagHint: "--target") }

        #expect(error?.localizedDescription == "No selection made for \"Choose targets\". Pass --target.")
    }

    @Test
    func `A required tree choice reports the flag that supplies it`() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredTreeNavigation(prompt: "Pick a folder", root: makeTreeRoot(), flagHint: "--path") }

        #expect(error?.localizedDescription == "No selection made for \"Pick a folder\". Pass --path.")
    }
}


// MARK: - Concurrency
extension NonInteractivePickerTests {
    @Test
    func `Consent resolves from another isolation domain`() async {
        let sut = makeSUT(assumeYes: true)
        let granted = await Task.detached { sut.getPermission(prompt: "Delete builds?") }.value

        #expect(granted)
    }
}


// MARK: - Helpers
private extension NonInteractivePickerTests {
    func makeItems() -> [TestItem] {
        return [TestFactory.makeItem(name: "First"), TestFactory.makeItem(name: "Second")]
    }

    func makeTreeRoot() -> TreeNavigationRoot<TreeTestItem> {
        return TreeNavigationRoot(displayName: "Root", children: [TestFactory.makeTreeItem(name: "Child")])
    }

    func makeDirectoryURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    func captureError(_ operation: () throws -> Void) -> Error? {
        do {
            try operation()
            return nil
        } catch {
            return error
        }
    }
}


// MARK: - SUT
private extension NonInteractivePickerTests {
    func makeSUT(assumeYes: Bool = false) -> NonInteractivePicker {
        return NonInteractivePicker(assumeYes: assumeYes)
    }
}
