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
    @Test("Starts with empty prompt history")
    func startsWithEmptyPromptHistory() {
        let sut = makeSUT()

        #expect(sut.capturedPrompts.isEmpty)
    }

    @Test("Accepts custom input configuration")
    func acceptsCustomInputConfiguration() {
        let responses = ["first", "second"]
        let inputResult = MockInputResult(type: .ordered(responses))
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
        let inputResult = MockInputResult(type: .ordered([response]))
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
        let sut = makeSUT(permissionResult: .init(type: .ordered([true, false])))

        _ = sut.getPermission(prompt: prompts[0])
        _ = sut.getPermission(prompt: prompts[1])

        #expect(sut.capturedPermissionPrompts == prompts)
    }

    @Test("Returns configured permission responses sequentially")
    func returnsConfiguredPermissionResponsesSequentially() {
        let responses: [Bool] = [true, false, true]
        let sut = makeSUT(permissionResult: .init(type: .ordered(responses)))

        #expect(sut.getPermission(prompt: "one") == responses[0])
        #expect(sut.getPermission(prompt: "two") == responses[1])
        #expect(sut.getPermission(prompt: "three") == responses[2])
    }

    @Test("Returns prompt specific permission responses from dictionary")
    func returnsPromptSpecificPermissionResponsesFromDictionary() {
        let mapping = ["allow?": true, "deny?": false]
        let sut = makeSUT(permissionResult: .init(type: .dictionary(mapping)))

        #expect(sut.getPermission(prompt: "allow?") == true)
        #expect(sut.getPermission(prompt: "deny?") == false)
    }

    @Test("requiredPermission throws when response is false")
    func requiredPermissionThrowsWhenResponseIsFalse() {
        let sut = makeSUT(permissionResult: .init(type: .ordered([false])))

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredPermission(prompt: "allow?")
        }
    }

    @Test("requiredPermission continues when response is true")
    func requiredPermissionContinuesWhenResponseIsTrue() throws {
        let sut = makeSUT(permissionResult: .init(type: .ordered([true])))

        try sut.requiredPermission(prompt: "allow?")
    }
}


// MARK: - Input Response Tests
extension MockSwiftPickerTests {
    @Test("Returns configured sequential responses")
    func returnsConfiguredSequentialResponses() {
        let responses = ["first", "second", "third"]
        let inputResult = MockInputResult(type: .ordered(responses))
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

        let inputResult = MockInputResult(type: .dictionary([
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
        let inputResult = MockInputResult(defaultValue: defaultValue, type: .ordered([]))
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
        let inputResult = MockInputResult(type: .ordered([expectedResponse]))
        let sut = makeSUT(inputResult: inputResult)

        let response = try sut.getRequiredInput(prompt: "Enter value")

        #expect(response == expectedResponse)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() throws {
        let emptyResponse = ""
        let inputResult = MockInputResult(defaultValue: emptyResponse, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: "Enter value")
        }
    }

    @Test("Throws input required error for empty response")
    func throwsInputRequiredErrorForEmptyResponse() throws {
        let inputResult = MockInputResult(defaultValue: "", type: .ordered([]))
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
        let inputResult = MockInputResult(defaultValue: emptyResponse, type: .ordered([]))
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
        let sut = makeSUT(selectionResult: .init(singleType: .ordered([.index(0), .index(1)])))

        _ = sut.singleSelection(prompt: prompts[0], items: ["red"], layout: .singleColumn, newScreen: false)
        _ = sut.singleSelection(prompt: prompts[1], items: ["square"], layout: .singleColumn, newScreen: false)

        #expect(sut.capturedSingleSelectionPrompts == prompts)
    }

    @Test("Records multi selection prompts in order")
    func recordsMultiSelectionPromptsInOrder() {
        let prompts = ["Pick toppings", "Pick extras"]
        let sut = makeSUT(selectionResult: .init(multiType: .ordered([.indices([]), .indices([])])))

        _ = sut.multiSelection(prompt: prompts[0], items: ["cheese"], layout: .singleColumn, newScreen: false)
        _ = sut.multiSelection(prompt: prompts[1], items: ["sauce"], layout: .singleColumn, newScreen: false)

        #expect(sut.capturedMultiSelectionPrompts == prompts)
    }

    @Test("Returns items using configured single selection indexes")
    func returnsItemsUsingConfiguredSingleSelectionIndexes() {
        let items = ["red", "blue", "green"]
        let sut = makeSUT(selectionResult: .init(singleType: .ordered([.index(1)])))

        let selection = sut.singleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false)

        #expect(selection == items[1])
    }

    @Test("Returns nil when single selection index is missing")
    func returnsNilWhenSingleSelectionIndexIsMissing() {
        let items = ["red", "blue"]
        let sut = makeSUT(selectionResult: .init(singleType: .ordered([.none])))

        let selection = sut.singleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false)

        #expect(selection == nil)
    }

    @Test("requiredSingleSelection throws when response is nil")
    func requiredSingleSelectionThrowsWhenResponseIsNil() {
        let sut = makeSUT(selectionResult: .init(singleType: .ordered([.none])))

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredSingleSelection(prompt: "Pick color", items: ["red"], layout: .singleColumn, newScreen: false)
        }
    }

    @Test("requiredSingleSelection returns item when index maps to value")
    func requiredSingleSelectionReturnsItemWhenIndexMapsToValue() throws {
        let items = ["red", "blue"]
        let sut = makeSUT(selectionResult: .init(singleType: .ordered([.index(1)])))

        let value = try sut.requiredSingleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false)

        #expect(value == items[1])
    }

    @Test("multiSelection returns items for configured indexes")
    func multiSelectionReturnsItemsForConfiguredIndexes() {
        let items = ["pepperoni", "mushroom", "olive"]
        let sut = makeSUT(selectionResult: .init(multiType: .ordered([.indices([0, 2])])))

        let result = sut.multiSelection(prompt: "Pick toppings", items: items, layout: .singleColumn, newScreen: false)

        #expect(result == ["pepperoni", "olive"])
    }

    @Test("multiSelection ignores indexes outside of bounds")
    func multiSelectionIgnoresIndexesOutsideOfBounds() {
        let items = ["pepperoni", "mushroom"]
        let sut = makeSUT(selectionResult: .init(multiType: .ordered([.indices([0, 5])])))

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
        let sut = makeSUT(treeNavigationResult: .init(type: .ordered([.index(0), .index(0)])))

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
        let sut = makeSUT(treeNavigationResult: .init(type: .ordered([.index(1)])))

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
        let sut = makeSUT(treeNavigationResult: .init(type: .ordered([.none])))

        let result = sut.treeNavigation(
            prompt: "Pick folder",
            rootItems: makeTreeNodes(["only"]),
            allowSelectingFolders: true,
            startInsideFirstRoot: false,
            newScreen: false
        )

        #expect(result == nil)
    }

    @Test("requiredTreeNavigation throws when selection missing")
    func requiredTreeNavigationThrowsWhenSelectionMissing() {
        let sut = makeSUT(treeNavigationResult: .init(type: .ordered([.none])))

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

    @Test("requiredTreeNavigation returns item when index maps")
    func requiredTreeNavigationReturnsItemWhenIndexMaps() throws {
        let nodes = makeTreeNodes(["first", "second"])
        let sut = makeSUT(treeNavigationResult: .init(type: .ordered([.index(1)])))

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
        return .init(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult,
            treeNavigationResult: treeNavigationResult
        )
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
