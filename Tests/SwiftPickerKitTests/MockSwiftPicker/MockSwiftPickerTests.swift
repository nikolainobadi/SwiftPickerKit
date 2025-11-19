//
//  MockSwiftPickerTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit
@testable import SwiftPickerTesting

struct MockSwiftPickerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let sut = makeSUT()

        #expect(sut.capturedPrompts.isEmpty)
        #expect(sut.capturedPermissionPrompts.isEmpty)
        #expect(sut.capturedSingleSelectionPrompts.isEmpty)
        #expect(sut.capturedMultiSelectionPrompts.isEmpty)
        #expect(sut.capturedTreeNavigationPrompts.isEmpty)
    }

    @Test("Starts with empty prompt history")
    func startsWithEmptyPromptHistory() {
        let sut = makeSUT()

        #expect(sut.capturedPrompts.isEmpty)
    }

    @Test("Accepts custom input configuration")
    func acceptsCustomInputConfiguration() {
        let responses = ["first", "second"]
        let inputResult = makeInputResult(type: .ordered(responses))
        let sut = makeSUT(inputResult: inputResult)

        let firstResponse = sut.getInput(prompt: "any")
        let secondResponse = sut.getInput(prompt: "any")

        #expect(firstResponse == responses[0])
        #expect(secondResponse == responses[1])
    }
}


// MARK: - Prompt Capture Tests
extension MockSwiftPickerTests {
    @Test("Records all prompts in order")
    func recordsAllPromptsInOrder() {
        let firstPrompt = "Enter name"
        let secondPrompt = "Enter email"
        let sut = makeSUT()

        _ = sut.getInput(prompt: firstPrompt)
        _ = sut.getInput(prompt: secondPrompt)

        #expect(sut.capturedPrompts.count == 2)
        #expect(sut.capturedPrompts[0] == firstPrompt)
        #expect(sut.capturedPrompts[1] == secondPrompt)
    }

    @Test("Records prompts from required input calls")
    func recordsPromptsFromRequiredInputCalls() throws {
        let prompt = "Enter value"
        let response = "non-empty"
        let inputResult = makeInputResult(type: .ordered([response]))
        let sut = makeSUT(inputResult: inputResult)

        _ = try sut.getRequiredInput(prompt: prompt)

        #expect(sut.capturedPrompts.contains(prompt))
    }

    @Test("Preserves prompt history across multiple calls")
    func preservesPromptHistoryAcrossMultipleCalls() {
        let prompts = ["first", "second", "third"]
        let sut = makeSUT()

        for prompt in prompts {
            _ = sut.getInput(prompt: prompt)
        }

        #expect(sut.capturedPrompts == prompts)
    }
}


// MARK: - Permission Tests
extension MockSwiftPickerTests {
    @Test("Starts with empty permission prompt history")
    func startsWithEmptyPermissionPromptHistory() {
        let sut = makeSUT()

        #expect(sut.capturedPermissionPrompts.isEmpty)
    }

    @Test("Records permission prompts in order")
    func recordsPermissionPromptsInOrder() {
        let prompts = ["Delete?", "Retry?"]
        let permissionResult = makePermissionResult(type: .ordered([true, false]))
        let sut = makeSUT(permissionResult: permissionResult)

        _ = sut.getPermission(prompt: prompts[0])
        _ = sut.getPermission(prompt: prompts[1])

        #expect(sut.capturedPermissionPrompts == prompts)
    }

    @Test("Returns configured permission responses sequentially")
    func returnsConfiguredPermissionResponsesSequentially() {
        let responses: [Bool] = [true, false, true]
        let permissionResult = makePermissionResult(type: .ordered(responses))
        let sut = makeSUT(permissionResult: permissionResult)

        #expect(sut.getPermission(prompt: "one") == responses[0])
        #expect(sut.getPermission(prompt: "two") == responses[1])
        #expect(sut.getPermission(prompt: "three") == responses[2])
    }

    @Test("Returns prompt specific permission responses from dictionary")
    func returnsPromptSpecificPermissionResponsesFromDictionary() {
        let mapping = ["allow?": true, "deny?": false]
        let permissionResult = makePermissionResult(type: .dictionary(mapping))
        let sut = makeSUT(permissionResult: permissionResult)

        #expect(sut.getPermission(prompt: "allow?") == true)
        #expect(sut.getPermission(prompt: "deny?") == false)
    }

    @Test("Throws when permission response is false")
    func throwsWhenPermissionResponseIsFalse() {
        let permissionResult = makePermissionResult(type: .ordered([false]))
        let sut = makeSUT(permissionResult: permissionResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredPermission(prompt: "allow?")
        }
    }

    @Test("Continues when permission response is true")
    func continuesWhenPermissionResponseIsTrue() throws {
        let permissionResult = makePermissionResult(type: .ordered([true]))
        let sut = makeSUT(permissionResult: permissionResult)

        try sut.requiredPermission(prompt: "allow?")
    }
}


// MARK: - Input Response Tests
extension MockSwiftPickerTests {
    @Test("Returns configured sequential responses")
    func returnsConfiguredSequentialResponses() {
        let responses = ["first", "second", "third"]
        let inputResult = makeInputResult(type: .ordered(responses))
        let sut = makeSUT(inputResult: inputResult)

        let first = sut.getInput(prompt: "any")
        let second = sut.getInput(prompt: "any")
        let third = sut.getInput(prompt: "any")

        #expect(first == responses[0])
        #expect(second == responses[1])
        #expect(third == responses[2])
    }

    @Test("Returns prompt-specific responses from dictionary")
    func returnsPromptSpecificResponsesFromDictionary() {
        let namePrompt = "Enter name"
        let emailPrompt = "Enter email"
        let nameResponse = "John"
        let emailResponse = "john@example.com"

        let inputResult = makeInputResult(type: .dictionary([
            namePrompt: nameResponse,
            emailPrompt: emailResponse
        ]))
        let sut = makeSUT(inputResult: inputResult)

        let name = sut.getInput(prompt: namePrompt)
        let email = sut.getInput(prompt: emailPrompt)

        #expect(name == nameResponse)
        #expect(email == emailResponse)
    }

    @Test("Falls back to default value for unconfigured prompts")
    func fallsBackToDefaultValueForUnconfiguredPrompts() {
        let defaultValue = "default"
        let inputResult = makeInputResult(defaultValue: defaultValue, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        let response = sut.getInput(prompt: "any")

        #expect(response == defaultValue)
    }
}


// MARK: - Required Input Tests
extension MockSwiftPickerTests {
    @Test("Returns non-empty response for required input")
    func returnsNonEmptyResponseForRequiredInput() throws {
        let expectedResponse = "valid input"
        let inputResult = makeInputResult(type: .ordered([expectedResponse]))
        let sut = makeSUT(inputResult: inputResult)

        let response = try sut.getRequiredInput(prompt: "Enter value")

        #expect(response == expectedResponse)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() throws {
        let emptyResponse = ""
        let inputResult = makeInputResult(defaultValue: emptyResponse, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: "Enter value")
        }
    }

    @Test("Throws input required error for empty response")
    func throwsInputRequiredErrorForEmptyResponse() throws {
        let inputResult = makeInputResult(defaultValue: "", type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        do {
            _ = try sut.getRequiredInput(prompt: "Enter value")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error as? SwiftPickerError == .inputRequired)
        }
    }

    @Test("Accepts empty string from optional input")
    func acceptsEmptyStringFromOptionalInput() {
        let emptyResponse = ""
        let inputResult = makeInputResult(defaultValue: emptyResponse, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        let response = sut.getInput(prompt: "Enter value")

        #expect(response.isEmpty)
    }
}


// MARK: - Selection Tests
extension MockSwiftPickerTests {
    @Test("Starts with empty single and multi selection histories")
    func startsWithEmptySelectionHistories() {
        let sut = makeSUT()

        #expect(sut.capturedSingleSelectionPrompts.isEmpty)
        #expect(sut.capturedMultiSelectionPrompts.isEmpty)
    }

    @Test("Records single selection prompts in order")
    func recordsSingleSelectionPromptsInOrder() {
        let prompts = ["Pick a color", "Pick a shape"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.index(0), .index(1)]))
        let sut = makeSUT(selectionResult: selectionResult)

        _ = sut.singleSelection(prompt: prompts[0], items: ["red"], layout: .singleColumn, newScreen: false)
        _ = sut.singleSelection(prompt: prompts[1], items: ["square"], layout: .singleColumn, newScreen: false)

        #expect(sut.capturedSingleSelectionPrompts == prompts)
    }

    @Test("Records multi selection prompts in order")
    func recordsMultiSelectionPromptsInOrder() {
        let prompts = ["Pick toppings", "Pick extras"]
        let selectionResult = makeSelectionResult(multiType: .ordered([.indices([]), .indices([])]))
        let sut = makeSUT(selectionResult: selectionResult)

        _ = sut.multiSelection(prompt: prompts[0], items: ["cheese"], layout: .singleColumn, newScreen: false)
        _ = sut.multiSelection(prompt: prompts[1], items: ["sauce"], layout: .singleColumn, newScreen: false)

        #expect(sut.capturedMultiSelectionPrompts == prompts)
    }

    @Test("Returns items using configured selection indexes")
    func returnsItemsUsingConfiguredSelectionIndexes() {
        let items = ["red", "blue", "green"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.index(1)]))
        let sut = makeSUT(selectionResult: selectionResult)

        let selection = sut.singleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false)

        #expect(selection == items[1])
    }

    @Test("Returns nil when single selection index is missing")
    func returnsNilWhenSingleSelectionIndexIsMissing() {
        let items = ["red", "blue"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.none]))
        let sut = makeSUT(selectionResult: selectionResult)

        let selection = sut.singleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false)

        #expect(selection == nil)
    }

    @Test("Throws when single selection outcome missing")
    func throwsWhenSingleSelectionOutcomeMissing() {
        let selectionResult = makeSelectionResult(singleType: .ordered([.none]))
        let sut = makeSUT(selectionResult: selectionResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredSingleSelection(prompt: "Pick color", items: ["red"], layout: .singleColumn, newScreen: false)
        }
    }

    @Test("Returns selected item matching configured index")
    func returnsSelectedItemMatchingConfiguredIndex() throws {
        let items = ["red", "blue"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.index(1)]))
        let sut = makeSUT(selectionResult: selectionResult)

        let value = try sut.requiredSingleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false)

        #expect(value == items[1])
    }

    @Test("Returns selected items for configured indices")
    func returnsSelectedItemsForConfiguredIndices() {
        let items = ["pepperoni", "mushroom", "olive"]
        let selectionResult = makeSelectionResult(multiType: .ordered([.indices([0, 2])]))
        let sut = makeSUT(selectionResult: selectionResult)

        let result = sut.multiSelection(prompt: "Pick toppings", items: items, layout: .singleColumn, newScreen: false)

        #expect(result == ["pepperoni", "olive"])
    }

    @Test("Ignores out of bounds indexes when building selection")
    func ignoresOutOfBoundsIndexesWhenBuildingSelection() {
        let items = ["pepperoni", "mushroom"]
        let selectionResult = makeSelectionResult(multiType: .ordered([.indices([0, 5])]))
        let sut = makeSUT(selectionResult: selectionResult)

        let result = sut.multiSelection(prompt: "Pick toppings", items: items, layout: .singleColumn, newScreen: false)

        #expect(result == ["pepperoni"])
    }
}


// MARK: - Tree Navigation Tests
extension MockSwiftPickerTests {
    @Test("Starts with empty tree navigation history")
    func startsWithEmptyTreeNavigationHistory() {
        let sut = makeSUT()

        #expect(sut.capturedTreeNavigationPrompts.isEmpty)
    }

    @Test("Records tree navigation prompts in order")
    func recordsTreeNavigationPromptsInOrder() {
        let prompts = ["Choose folder", "Choose project"]
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.index(0), .index(0)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        _ = sut.treeNavigation(
            prompt: prompts[0],
            rootItems: makeTreeNodes(["first"]),
            allowSelectingFolders: true,
            startInsideFirstRoot: false,
            newScreen: false
        )

        _ = sut.treeNavigation(
            prompt: prompts[1],
            rootItems: makeTreeNodes(["second"]),
            allowSelectingFolders: true,
            startInsideFirstRoot: false,
            newScreen: false
        )

        #expect(sut.capturedTreeNavigationPrompts == prompts)
    }

    @Test("Returns tree navigation items using configured indexes")
    func returnsTreeNavigationItemsUsingConfiguredIndexes() {
        let nodes = makeTreeNodes(["first", "second"])
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.index(1)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = sut.treeNavigation(
            prompt: "Pick folder",
            rootItems: nodes,
            allowSelectingFolders: true,
            startInsideFirstRoot: false,
            newScreen: false
        )

        #expect(result == nodes[1])
    }

    @Test("Returns nil when tree navigation outcome is missing")
    func returnsNilWhenTreeNavigationOutcomeIsMissing() {
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.none]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = sut.treeNavigation(
            prompt: "Pick folder",
            rootItems: makeTreeNodes(["only"]),
            allowSelectingFolders: true,
            startInsideFirstRoot: false,
            newScreen: false
        )

        #expect(result == nil)
    }

    @Test("Throws when tree navigation selection missing")
    func throwsWhenTreeNavigationSelectionMissing() {
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.none]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredTreeNavigation(
                prompt: "Pick folder",
                rootItems: makeTreeNodes(["only"]),
                allowSelectingFolders: true,
                startInsideFirstRoot: false,
                newScreen: false
            )
        }
    }

    @Test("Returns tree navigation item matching configured index")
    func returnsTreeNavigationItemMatchingConfiguredIndex() throws {
        let nodes = makeTreeNodes(["first", "second"])
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.index(1)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = try sut.requiredTreeNavigation(
            prompt: "Pick folder",
            rootItems: nodes,
            allowSelectingFolders: true,
            startInsideFirstRoot: false,
            newScreen: false
        )

        #expect(result == nodes[1])
    }
}


// MARK: - SUT
private extension MockSwiftPickerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        treeNavigationResult: MockTreeNavigationResult = .init()
    ) -> MockSwiftPicker {
        return makeSwiftPicker(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult,
            treeNavigationResult: treeNavigationResult
        )
    }

    func makeSwiftPicker(
        inputResult: MockInputResult,
        permissionResult: MockPermissionResult,
        selectionResult: MockSelectionResult,
        treeNavigationResult: MockTreeNavigationResult
    ) -> MockSwiftPicker {
        return MockSwiftPicker(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult,
            treeNavigationResult: treeNavigationResult
        )
    }

    func makeInputResult(defaultValue: String = "", type: MockInputType = .ordered([])) -> MockInputResult {
        return MockInputResult(defaultValue: defaultValue, type: type)
    }

    func makePermissionResult(defaultValue: Bool = false, type: MockPermissionType = .ordered([])) -> MockPermissionResult {
        return MockPermissionResult(defaultValue: defaultValue, type: type)
    }

    func makeSelectionResult(
        defaultSingle: MockSingleSelectionOutcome = .none,
        defaultMulti: MockMultiSelectionOutcome = .none,
        singleType: MockSingleSelectionType = .ordered([]),
        multiType: MockMultiSelectionType = .ordered([])
    ) -> MockSelectionResult {
        return MockSelectionResult(
            defaultSingle: defaultSingle,
            defaultMulti: defaultMulti,
            singleType: singleType,
            multiType: multiType
        )
    }

    func makeTreeNavigationResult(
        defaultOutcome: MockTreeSelectionOutcome = .none,
        type: MockTreeSelectionType = .ordered([])
    ) -> MockTreeNavigationResult {
        return MockTreeNavigationResult(defaultOutcome: defaultOutcome, type: type)
    }

    func makeTreeNodes(_ names: [String]) -> [MockTreeNode] {
        return names.map { MockTreeNode(name: $0) }
    }
}


// MARK: - Helpers
private struct MockTreeNode: TreeNodePickerItem, Equatable {
    let name: String
    var children: [MockTreeNode] = []

    var displayName: String { name }
    var hasChildren: Bool { !children.isEmpty }
    func loadChildren() -> [MockTreeNode] { children }
    var metadata: TreeNodeMetadata? { nil }
}
