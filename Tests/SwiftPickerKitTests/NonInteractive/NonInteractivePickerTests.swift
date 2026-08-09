//
//  NonInteractivePickerTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Testing
import Foundation
@testable import SwiftPickerKit

struct NonInteractivePickerTests {
    @Test("Returns empty input without prompting")
    func returnsEmptyInputWithoutPrompting() {
        let sut = makeSUT()

        #expect(sut.getInput(prompt: "Project name").isEmpty)
    }

    @Test("Denies permission by default")
    func deniesPermissionByDefault() {
        let sut = makeSUT()

        #expect(!sut.getPermission(prompt: "Continue?"))
    }

    @Test("Grants permission when assuming yes")
    func grantsPermissionWhenAssumingYes() {
        let sut = makeSUT(assumeYes: true)

        #expect(sut.getPermission(prompt: "Continue?"))
    }

    @Test("Returns nil for single selection")
    func returnsNilForSingleSelection() {
        let sut = makeSUT()

        #expect(sut.singleSelection(prompt: "Choose", items: makeItems()) == nil)
    }

    @Test("Returns empty array for multi selection")
    func returnsEmptyArrayForMultiSelection() {
        let sut = makeSUT()

        #expect(sut.multiSelection(prompt: "Choose", items: makeItems()).isEmpty)
    }

    @Test("Returns nil for tree navigation")
    func returnsNilForTreeNavigation() {
        let sut = makeSUT()

        #expect(sut.treeNavigation(prompt: "Browse", root: makeTreeRoot(), showPromptText: true, showSelectedItemText: true) == nil)
    }

}


// MARK: - Derived Throwing Behavior
extension NonInteractivePickerTests {
    @Test("Required input throws inputRequired")
    func requiredInputThrowsInputRequired() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.inputRequired) {
            _ = try sut.getRequiredInput(prompt: "Project name")
        }
    }

    @Test("Required permission throws when not assuming yes")
    func requiredPermissionThrowsWhenNotAssumingYes() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.requiredPermission(prompt: "Continue?")
        }
    }

    @Test("Required permission succeeds when assuming yes")
    func requiredPermissionSucceedsWhenAssumingYes() throws {
        let sut = makeSUT(assumeYes: true)

        try sut.requiredPermission(prompt: "Continue?")
    }

    @Test("Required single selection throws selectionCancelled")
    func requiredSingleSelectionThrowsSelectionCancelled() {
        let sut = makeSUT()

        // The labeled variant declares no defaults (CommandLineSelection.swift:84), so the
        // unlabeled overload is the existing convenience form.
        #expect(throws: SwiftPickerError.selectionCancelled) {
            _ = try sut.requiredSingleSelection("Choose", items: makeItems())
        }
    }

    @Test("Required tree navigation throws selectionCancelled")
    func requiredTreeNavigationThrowsSelectionCancelled() {
        let sut = makeSUT()

        #expect(throws: SwiftPickerError.selectionCancelled) {
            _ = try sut.requiredTreeNavigation(prompt: "Browse", root: makeTreeRoot())
        }
    }
}


// MARK: - Flag Hint Overloads
extension NonInteractivePickerTests {
    @Test("Required input with flag hint reports the flag")
    func requiredInputWithFlagHintReportsTheFlag() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.getRequiredInput(prompt: "Project name", flagHint: "--name") }

        guard case .missingInput(let prompt, let flagHint)? = error as? PickerRequirementError else {
            Issue.record("Expected missingInput, got \(String(describing: error))")
            return
        }

        #expect(prompt == "Project name")
        #expect(flagHint == "--name")
        #expect(error?.localizedDescription.contains("--name") == true)
    }

    @Test("Required permission with flag hint reports the flag")
    func requiredPermissionWithFlagHintReportsTheFlag() {
        let sut = makeSUT()
        let error = captureError { try sut.requiredPermission(prompt: "Delete builds?", flagHint: "--force") }

        guard case .confirmationRequired(let prompt, let flagHint)? = error as? PickerRequirementError else {
            Issue.record("Expected confirmationRequired, got \(String(describing: error))")
            return
        }

        #expect(prompt == "Delete builds?")
        #expect(flagHint == "--force")
        #expect(error?.localizedDescription.contains("--force") == true)
    }

    @Test("Required permission with flag hint succeeds when assuming yes")
    func requiredPermissionWithFlagHintSucceedsWhenAssumingYes() throws {
        let sut = makeSUT(assumeYes: true)

        try sut.requiredPermission(prompt: "Delete builds?", flagHint: "--force")
    }

    @Test("Required single selection with flag hint reports the flag")
    func requiredSingleSelectionWithFlagHintReportsTheFlag() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredSingleSelection(prompt: "Choose a project", items: makeItems(), flagHint: "--project") }

        guard case .missingSelection(let prompt, let flagHint)? = error as? PickerRequirementError else {
            Issue.record("Expected missingSelection, got \(String(describing: error))")
            return
        }

        #expect(prompt == "Choose a project")
        #expect(flagHint == "--project")
        #expect(error?.localizedDescription.contains("--project") == true)
    }

    @Test("Required multi selection with flag hint reports the flag")
    func requiredMultiSelectionWithFlagHintReportsTheFlag() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredMultiSelection(prompt: "Choose targets", items: makeItems(), flagHint: "--target") }

        guard case .missingSelection(let prompt, let flagHint)? = error as? PickerRequirementError else {
            Issue.record("Expected missingSelection, got \(String(describing: error))")
            return
        }

        #expect(prompt == "Choose targets")
        #expect(flagHint == "--target")
        #expect(error?.localizedDescription.contains("--target") == true)
    }

    @Test("Required tree navigation with flag hint reports the flag")
    func requiredTreeNavigationWithFlagHintReportsTheFlag() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredTreeNavigation(prompt: "Pick a folder", root: makeTreeRoot(), flagHint: "--path") }

        guard case .missingSelection(let prompt, let flagHint)? = error as? PickerRequirementError else {
            Issue.record("Expected missingSelection, got \(String(describing: error))")
            return
        }

        #expect(prompt == "Pick a folder")
        #expect(flagHint == "--path")
        #expect(error?.localizedDescription.contains("--path") == true)
    }
}


// MARK: - Overload Resolution Guards
extension NonInteractivePickerTests {
    // These fail if a future change gives `flagHint` a default value. Swift prefers the
    // candidate applying fewer default arguments, so a defaulted `flagHint` would leave the
    // new overloads unreachable while these calls silently kept the old behavior.

    @Test("Permission without a flag hint keeps throwing SwiftPickerError")
    func permissionWithoutFlagHintKeepsThrowingSwiftPickerError() {
        let sut = makeSUT()
        let error = captureError { try sut.requiredPermission(prompt: "Continue?") }

        #expect(error is SwiftPickerError)
        #expect(!(error is PickerRequirementError))
    }

    @Test("Single selection without a flag hint keeps throwing SwiftPickerError")
    func singleSelectionWithoutFlagHintKeepsThrowingSwiftPickerError() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredSingleSelection("Choose", items: makeItems()) }

        #expect(error is SwiftPickerError)
        #expect(!(error is PickerRequirementError))
    }

    @Test("Fully argumented single selection keeps throwing SwiftPickerError")
    func fullyArgumentedSingleSelectionKeepsThrowingSwiftPickerError() {
        let sut = makeSUT()
        let error = captureError {
            _ = try sut.requiredSingleSelection(prompt: "Choose", items: makeItems(), layout: .singleColumn, newScreen: true, showSelectedItemText: true)
        }

        #expect(error is SwiftPickerError)
        #expect(!(error is PickerRequirementError))
    }

    @Test("Tree navigation without a flag hint keeps throwing SwiftPickerError")
    func treeNavigationWithoutFlagHintKeepsThrowingSwiftPickerError() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.requiredTreeNavigation(prompt: "Browse", root: makeTreeRoot()) }

        #expect(error is SwiftPickerError)
        #expect(!(error is PickerRequirementError))
    }

    @Test("Input without a flag hint keeps throwing SwiftPickerError")
    func inputWithoutFlagHintKeepsThrowingSwiftPickerError() {
        let sut = makeSUT()
        let error = captureError { _ = try sut.getRequiredInput(prompt: "Project name") }

        #expect(error is SwiftPickerError)
        #expect(!(error is PickerRequirementError))
    }
}


// MARK: - Error Messages
extension NonInteractivePickerTests {
    @Test("Missing input message names the flag")
    func missingInputMessageNamesTheFlag() {
        let error = PickerRequirementError.missingInput(prompt: "Project name", flagHint: "--name")

        #expect(error.errorDescription == "Missing required value for \"Project name\". Pass --name.")
    }

    @Test("Missing selection message names the flag")
    func missingSelectionMessageNamesTheFlag() {
        let error = PickerRequirementError.missingSelection(prompt: "Choose a target", flagHint: "--target")

        #expect(error.errorDescription == "No selection made for \"Choose a target\". Pass --target.")
    }

    @Test("Confirmation message falls back to the yes flag")
    func confirmationMessageFallsBackToTheYesFlag() {
        let error = PickerRequirementError.confirmationRequired(prompt: "Delete all builds?", flagHint: nil)

        #expect(error.errorDescription == "Confirmation required for \"Delete all builds?\". Pass --yes.")
    }

    @Test("Message without a flag hint suggests an argument")
    func messageWithoutFlagHintSuggestsAnArgument() {
        let error = PickerRequirementError.missingInput(prompt: "Project name", flagHint: nil)

        #expect(error.errorDescription == "Missing required value for \"Project name\". Provide it as an argument.")
    }

    @Test("Messages never mention the picker mode")
    func messagesNeverMentionThePickerMode() {
        // The same overloads fire for a live SwiftPicker, so the text has to read correctly
        // whether or not the run was interactive.
        let errors: [PickerRequirementError] = [
            .missingInput(prompt: "Name", flagHint: "--name"),
            .missingSelection(prompt: "Target", flagHint: "--target"),
            .confirmationRequired(prompt: "Delete?", flagHint: "--force")
        ]

        for error in errors {
            let message = error.errorDescription ?? ""

            #expect(!message.lowercased().contains("non-interactive"))
            #expect(!message.lowercased().contains("interactive"))
        }
    }
}


// MARK: - Concurrency
extension NonInteractivePickerTests {
    @Test("Crosses an isolation boundary")
    func crossesAnIsolationBoundary() async {
        let sut = makeSUT(assumeYes: true)
        let granted = await Task.detached { sut.getPermission(prompt: "Continue?") }.value

        #expect(granted)
    }
}


// MARK: - SUT
private extension NonInteractivePickerTests {
    func makeSUT(assumeYes: Bool = false) -> NonInteractivePicker {
        return NonInteractivePicker(assumeYes: assumeYes)
    }

    func makeItems() -> [TestItem] {
        return [TestItem(name: "First"), TestItem(name: "Second")]
    }

    func makeTreeRoot() -> TreeNavigationRoot<TreeTestItem> {
        let child = TreeTestItem(name: "Child", children: [], metadata: nil, hasChildrenValue: false, isSelectable: true)

        return TreeNavigationRoot(displayName: "Root", children: [child])
    }

    func makeTemporaryURL() -> URL {
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
