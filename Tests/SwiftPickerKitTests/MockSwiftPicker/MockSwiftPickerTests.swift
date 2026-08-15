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
    @Test
    func `Starting values empty`() {
        let sut = makeSUT()

        #expect(sut.capturedPrompts.isEmpty)
        #expect(sut.capturedPermissionPrompts.isEmpty)
        #expect(sut.capturedSingleSelectionPrompts.isEmpty)
        #expect(sut.capturedMultiSelectionPrompts.isEmpty)
        #expect(sut.capturedTreeNavigationPrompts.isEmpty)
    }

    @Test
    func `Starts with empty prompt history`() {
        let sut = makeSUT()

        #expect(sut.capturedPrompts.isEmpty)
    }

    @Test
    func `Accepts custom input configuration`() {
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
    @Test
    func `Records all prompts in order`() {
        let firstPrompt = "Enter name"
        let secondPrompt = "Enter email"
        let sut = makeSUT()

        _ = sut.getInput(prompt: firstPrompt)
        _ = sut.getInput(prompt: secondPrompt)

        #expect(sut.capturedPrompts.count == 2)
        #expect(sut.capturedPrompts[0] == firstPrompt)
        #expect(sut.capturedPrompts[1] == secondPrompt)
    }

    @Test
    func `Records prompts from required input calls`() throws {
        let prompt = "Enter value"
        let response = "non-empty"
        let inputResult = makeInputResult(type: .ordered([response]))
        let sut = makeSUT(inputResult: inputResult)

        _ = try sut.getRequiredInput(prompt: prompt)

        #expect(sut.capturedPrompts.contains(prompt))
    }

    @Test
    func `Preserves prompt history across multiple calls`() {
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
    @Test
    func `Starts with empty permission prompt history`() {
        let sut = makeSUT()

        #expect(sut.capturedPermissionPrompts.isEmpty)
    }

    @Test
    func `Records permission prompts in order`() {
        let prompts = ["Delete?", "Retry?"]
        let permissionResult = makePermissionResult(type: .ordered([true, false]))
        let sut = makeSUT(permissionResult: permissionResult)

        _ = sut.getPermission(prompt: prompts[0])
        _ = sut.getPermission(prompt: prompts[1])

        #expect(sut.capturedPermissionPrompts == prompts)
    }

    @Test
    func `Returns configured permission responses sequentially`() {
        let responses: [Bool] = [true, false, true]
        let permissionResult = makePermissionResult(type: .ordered(responses))
        let sut = makeSUT(permissionResult: permissionResult)

        #expect(sut.getPermission(prompt: "one") == responses[0])
        #expect(sut.getPermission(prompt: "two") == responses[1])
        #expect(sut.getPermission(prompt: "three") == responses[2])
    }

    @Test
    func `Returns prompt specific permission responses from dictionary`() {
        let mapping = ["allow?": true, "deny?": false]
        let permissionResult = makePermissionResult(type: .dictionary(mapping))
        let sut = makeSUT(permissionResult: permissionResult)

        #expect(sut.getPermission(prompt: "allow?") == true)
        #expect(sut.getPermission(prompt: "deny?") == false)
    }

    @Test
    func `Throws when permission response is false`() {
        let permissionResult = makePermissionResult(type: .ordered([false]))
        let sut = makeSUT(permissionResult: permissionResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredPermission(prompt: "allow?")
        }
    }

    @Test
    func `Continues when permission response is true`() throws {
        let permissionResult = makePermissionResult(type: .ordered([true]))
        let sut = makeSUT(permissionResult: permissionResult)

        try sut.requiredPermission(prompt: "allow?")
    }
}


// MARK: - Input Response Tests
extension MockSwiftPickerTests {
    @Test
    func `Returns configured sequential responses`() {
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

    @Test
    func `Returns prompt-specific responses from dictionary`() {
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

    @Test
    func `Falls back to default value for unconfigured prompts`() {
        let defaultValue = "default"
        let inputResult = makeInputResult(defaultValue: defaultValue, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        let response = sut.getInput(prompt: "any")

        #expect(response == defaultValue)
    }
}


// MARK: - Required Input Tests
extension MockSwiftPickerTests {
    @Test
    func `Returns non-empty response for required input`() throws {
        let expectedResponse = "valid input"
        let inputResult = makeInputResult(type: .ordered([expectedResponse]))
        let sut = makeSUT(inputResult: inputResult)

        let response = try sut.getRequiredInput(prompt: "Enter value")

        #expect(response == expectedResponse)
    }

    @Test
    func `Throws error when required input is empty`() throws {
        let emptyResponse = ""
        let inputResult = makeInputResult(defaultValue: emptyResponse, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: "Enter value")
        }
    }

    @Test
    func `Throws input required error for empty response`() throws {
        let inputResult = makeInputResult(defaultValue: "", type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        do {
            _ = try sut.getRequiredInput(prompt: "Enter value")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error as? SwiftPickerError == .inputRequired)
        }
    }

    @Test
    func `Accepts empty string from optional input`() {
        let emptyResponse = ""
        let inputResult = makeInputResult(defaultValue: emptyResponse, type: .ordered([]))
        let sut = makeSUT(inputResult: inputResult)

        let response = sut.getInput(prompt: "Enter value")

        #expect(response.isEmpty)
    }
}


// MARK: - Selection Tests
extension MockSwiftPickerTests {
    @Test
    func `Starts with empty single and multi selection histories`() {
        let sut = makeSUT()

        #expect(sut.capturedSingleSelectionPrompts.isEmpty)
        #expect(sut.capturedMultiSelectionPrompts.isEmpty)
    }

    @Test
    func `Records single selection prompts in order`() {
        let prompts = ["Pick a color", "Pick a shape"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.index(0), .index(1)]))
        let sut = makeSUT(selectionResult: selectionResult)

        _ = sut.singleSelection(prompt: prompts[0], items: ["red"], layout: .singleColumn, newScreen: false, showSelectedItemText: true)
        _ = sut.singleSelection(prompt: prompts[1], items: ["square"], layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(sut.capturedSingleSelectionPrompts == prompts)
    }

    @Test
    func `Records multi selection prompts in order`() {
        let prompts = ["Pick toppings", "Pick extras"]
        let selectionResult = makeSelectionResult(multiType: .ordered([.indices([]), .indices([])]))
        let sut = makeSUT(selectionResult: selectionResult)

        _ = sut.multiSelection(prompt: prompts[0], items: ["cheese"], layout: .singleColumn, newScreen: false, showSelectedItemText: true)
        _ = sut.multiSelection(prompt: prompts[1], items: ["sauce"], layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(sut.capturedMultiSelectionPrompts == prompts)
    }

    @Test
    func `Returns items using configured selection indexes`() {
        let items = ["red", "blue", "green"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.index(1)]))
        let sut = makeSUT(selectionResult: selectionResult)

        let selection = sut.singleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(selection == items[1])
    }

    @Test
    func `Returns nil when single selection index is missing`() {
        let items = ["red", "blue"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.none]))
        let sut = makeSUT(selectionResult: selectionResult)

        let selection = sut.singleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(selection == nil)
    }

    @Test
    func `Throws when single selection outcome missing`() {
        let selectionResult = makeSelectionResult(singleType: .ordered([.none]))
        let sut = makeSUT(selectionResult: selectionResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredSingleSelection(prompt: "Pick color", items: ["red"], layout: .singleColumn, newScreen: false, showSelectedItemText: true)
        }
    }

    @Test
    func `Returns selected item matching configured index`() throws {
        let items = ["red", "blue"]
        let selectionResult = makeSelectionResult(singleType: .ordered([.index(1)]))
        let sut = makeSUT(selectionResult: selectionResult)

        let value = try sut.requiredSingleSelection(prompt: "Pick color", items: items, layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(value == items[1])
    }

    @Test
    func `Returns selected items for configured indices`() {
        let items = ["pepperoni", "mushroom", "olive"]
        let selectionResult = makeSelectionResult(multiType: .ordered([.indices([0, 2])]))
        let sut = makeSUT(selectionResult: selectionResult)

        let result = sut.multiSelection(prompt: "Pick toppings", items: items, layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(result == ["pepperoni", "olive"])
    }

    @Test
    func `Ignores out of bounds indexes when building selection`() {
        let items = ["pepperoni", "mushroom"]
        let selectionResult = makeSelectionResult(multiType: .ordered([.indices([0, 5])]))
        let sut = makeSUT(selectionResult: selectionResult)

        let result = sut.multiSelection(prompt: "Pick toppings", items: items, layout: .singleColumn, newScreen: false, showSelectedItemText: true)

        #expect(result == ["pepperoni"])
    }
}


// MARK: - Tree Navigation Tests
extension MockSwiftPickerTests {
    @Test
    func `Starts with empty tree navigation history`() {
        let sut = makeSUT()

        #expect(sut.capturedTreeNavigationPrompts.isEmpty)
    }

    @Test
    func `Records tree navigation prompts in order`() {
        let prompts = ["Choose folder", "Choose project"]
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.index(0), .index(0)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        _ = sut.treeNavigation(
            prompt: prompts[0],
            root: makeTreeRoot(["first"]),
            showPromptText: true,
            showSelectedItemText: true
        )

        _ = sut.treeNavigation(
            prompt: prompts[1],
            root: makeTreeRoot(["second"]),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(sut.capturedTreeNavigationPrompts == prompts)
    }

    @Test
    func `Returns tree navigation items using configured indexes`() {
        let nodes = makeTreeNodes(["first", "second"])
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.index(1)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = sut.treeNavigation(
            prompt: "Pick folder",
            root: makeTreeRoot(nodes),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result == nodes[1])
    }

    @Test
    func `Returns nil when tree navigation outcome is missing`() {
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.none]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = sut.treeNavigation(
            prompt: "Pick folder",
            root: makeTreeRoot(["only"]),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result == nil)
    }

    @Test
    func `Throws when tree navigation selection missing`() {
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.none]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredTreeNavigation(
                prompt: "Pick folder",
                root: makeTreeRoot(["only"]),
                showPromptText: true,
                showSelectedItemText: true
            )
        }
    }

    @Test
    func `Returns tree navigation item matching configured index`() throws {
        let nodes = makeTreeNodes(["first", "second"])
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.index(1)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = try sut.requiredTreeNavigation(
            prompt: "Pick folder",
            root: makeTreeRoot(nodes),
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result == nodes[1])
    }

    @Test
    func `Returns child item using configured parent and child indexes`() {
        let children = makeTreeNodes(["child 1", "child 2"])
        let parent = MockTreeNode(name: "Parent", children: children)
        let root = makeTreeRoot([parent])
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.child(parentIndex: 0, childIndex: 1)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = sut.treeNavigation(
            prompt: "Pick file",
            root: root,
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result == children[1])
    }

    @Test
    func `Returns nil when child index is out of bounds`() {
        let children = makeTreeNodes(["child"])
        let parent = MockTreeNode(name: "Parent", children: children)
        let root = makeTreeRoot([parent])
        let treeNavigationResult = makeTreeNavigationResult(type: .ordered([.child(parentIndex: 0, childIndex: 5)]))
        let sut = makeSUT(treeNavigationResult: treeNavigationResult)

        let result = sut.treeNavigation(
            prompt: "Pick file",
            root: root,
            showPromptText: true,
            showSelectedItemText: true
        )

        #expect(result == nil)
    }
}


// MARK: - Helpers
private extension MockSwiftPickerTests {
    func makeSwiftPicker(
        inputResult: MockInputResult,
        permissionResult: MockPermissionResult,
        selectionResult: MockSelectionResult,
        treeNavigationResult: MockTreeNavigationResult
    ) -> MockSwiftPicker {
        return .init(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult,
            treeNavigationResult: treeNavigationResult
        )
    }

    func makeInputResult(defaultValue: String = "", type: MockInputType = .ordered([])) -> MockInputResult {
        return .init(defaultValue: defaultValue, type: type)
    }

    func makePermissionResult(defaultValue: Bool = false, type: MockPermissionType = .ordered([])) -> MockPermissionResult {
        return .init(defaultValue: defaultValue, type: type)
    }

    func makeSelectionResult(
        defaultSingle: MockSingleSelectionOutcome = .none,
        defaultMulti: MockMultiSelectionOutcome = .none,
        singleType: MockSingleSelectionType = .ordered([]),
        multiType: MockMultiSelectionType = .ordered([])
    ) -> MockSelectionResult {
        return .init(
            defaultSingle: defaultSingle,
            defaultMulti: defaultMulti,
            singleType: singleType,
            multiType: multiType
        )
    }

    func makeTreeNavigationResult(defaultOutcome: MockTreeSelectionOutcome = .none, type: MockTreeSelectionType = .ordered([])) -> MockTreeNavigationResult {
        return .init(defaultOutcome: defaultOutcome, type: type)
    }

    func makeTreeNodes(_ names: [String]) -> [MockTreeNode] {
        return names.map { .init(name: $0) }
    }

    func makeTreeRoot(_ names: [String]) -> TreeNavigationRoot<MockTreeNode> {
        let nodes = makeTreeNodes(names)
        return .init(displayName: "Root", children: nodes)
    }

    func makeTreeRoot(_ nodes: [MockTreeNode]) -> TreeNavigationRoot<MockTreeNode> {
        return .init(displayName: "Root", children: nodes)
    }
}


// MARK: - Helpers
private struct MockTreeNode: TreeNodePickerItem, Equatable {
    let name: String
    var children: [MockTreeNode] = []
    var isSelectable: Bool = true

    var displayName: String { name }
    var hasChildren: Bool { !children.isEmpty }
    func loadChildren() -> [MockTreeNode] { children }
    var metadata: TreeNodeMetadata? { nil }
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
}
