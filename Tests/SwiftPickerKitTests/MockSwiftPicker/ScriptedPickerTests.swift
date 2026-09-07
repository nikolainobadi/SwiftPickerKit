//
//  ScriptedPickerTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 9/6/26.
//

import Testing
@testable import SwiftPickerKit
@testable import SwiftPickerTesting

struct ScriptedPickerTests {
    @Test
    func `Answers input prompts from the queue in order`() {
        let inputs = ["first", "second"]
        let sut = makeSUT(inputs: inputs)

        #expect(sut.getInput(prompt: "any") == inputs[0])
        #expect(sut.getInput(prompt: "any") == inputs[1])
    }

    @Test
    func `Answers permission prompts from the queue in order`() {
        let permissions = [true, false, true]
        let sut = makeSUT(permissions: permissions)

        #expect(sut.getPermission(prompt: "one") == permissions[0])
        #expect(sut.getPermission(prompt: "two") == permissions[1])
        #expect(sut.getPermission(prompt: "three") == permissions[2])
    }

    @Test
    func `Advances each queue independently of the others`() {
        let sut = makeSUT(permissions: [true], inputs: ["only"])

        _ = sut.getPermission(prompt: "permission first")

        #expect(sut.getInput(prompt: "input second") == "only")
    }
}


// MARK: - Exhaustion Tests
extension ScriptedPickerTests {
    @Test
    func `Falls back to an empty string once the input queue is drained`() {
        let sut = makeSUT(inputs: ["only"])

        #expect(sut.getInput(prompt: "any") == "only")
        #expect(sut.getInput(prompt: "any") == "")
        #expect(sut.getInput(prompt: "any") == "")
    }

    @Test
    func `Falls back to false once the permission queue is drained`() {
        let sut = makeSUT(permissions: [true])

        #expect(sut.getPermission(prompt: "any") == true)
        #expect(sut.getPermission(prompt: "any") == false)
        #expect(sut.getPermission(prompt: "any") == false)
    }

    @Test
    func `Falls back to no selection once the single queue is drained`() {
        let items = ["red", "blue"]
        let sut = makeSUT(singles: [.index(1)])

        #expect(singleSelection(on: sut, items: items) == items[1])
        #expect(singleSelection(on: sut, items: items) == nil)
    }

    @Test
    func `Falls back to an empty selection once the multi queue is drained`() {
        let items = ["red", "blue"]
        let sut = makeSUT(multis: [.indices([0, 1])])

        #expect(multiSelection(on: sut, items: items) == items)
        #expect(multiSelection(on: sut, items: items) == [])
    }
}


// MARK: - Tree Navigation Tests
extension ScriptedPickerTests {
    @Test
    func `Answers tree navigation from the queue in order`() {
        let items = makeTreeItems(names: ["first", "second"])
        let sut = makeSUT(treeNavigations: [.index(1)])

        let result = treeNavigation(on: sut, items: items)

        #expect(result?.displayName == items[1].displayName)
    }

    @Test
    func `Falls back to no selection once the tree queue is drained`() {
        let items = makeTreeItems(names: ["first", "second"])
        let sut = makeSUT(treeNavigations: [.index(0)])

        #expect(treeNavigation(on: sut, items: items)?.displayName == items[0].displayName)
        #expect(treeNavigation(on: sut, items: items) == nil)
    }

    @Test
    func `Returns nil for tree navigation when the queue is empty`() {
        let items = makeTreeItems(names: ["only"])
        let sut = makeSUT()

        #expect(treeNavigation(on: sut, items: items) == nil)
    }
}


// MARK: - Silent Tests
extension ScriptedPickerTests {
    @Test
    func `Silent answers every prompt kind with its fallback`() {
        let items = ["red", "blue"]
        let sut = ScriptedPicker.silent()

        #expect(sut.getInput(prompt: "any") == "")
        #expect(sut.getPermission(prompt: "any") == false)
        #expect(singleSelection(on: sut, items: items) == nil)
        #expect(multiSelection(on: sut, items: items) == [])
    }

    @Test
    func `Silent still records the prompts it was asked`() {
        let inputPrompt = "Enter name"
        let permissionPrompt = "Overwrite?"
        let sut = ScriptedPicker.silent()

        _ = sut.getInput(prompt: inputPrompt)
        _ = sut.getPermission(prompt: permissionPrompt)

        #expect(sut.capturedPrompts == [inputPrompt])
        #expect(sut.capturedPermissionPrompts == [permissionPrompt])
    }
}


// MARK: - Default Agreement Tests
extension ScriptedPickerTests {
    // ScriptedPicker.make passes the fallbacks as literals rather than letting the Mock*Result
    // initializers supply them, so the same four values are declared in two places. This pins that
    // they agree: change a Mock*Result default without changing ScriptedPicker and this fails.
    //
    // This is the one call site in the suite that deliberately relies on default arguments. Naming
    // them here would compare the literals against themselves and detect nothing, which is exactly
    // the bug this test exists to catch.
    @Test
    func `Scripted fallbacks match the mock's own defaults`() {
        let items = ["red", "blue"]
        let scripted = ScriptedPicker.silent()
        let bare = MockSwiftPicker()

        #expect(scripted.getInput(prompt: "any") == bare.getInput(prompt: "any"))
        #expect(scripted.getPermission(prompt: "any") == bare.getPermission(prompt: "any"))
        #expect(singleSelection(on: scripted, items: items) == singleSelection(on: bare, items: items))
        #expect(multiSelection(on: scripted, items: items) == multiSelection(on: bare, items: items))
    }
}


// MARK: - Prompt Capture Tests
extension ScriptedPickerTests {
    @Test
    func `Records prompts for every kind of question`() {
        let items = ["red"]
        let sut = makeSUT(permissions: [true], singles: [.index(0)], multis: [.indices([0])], inputs: ["name"])

        _ = sut.getInput(prompt: "Enter name")
        _ = sut.getPermission(prompt: "Overwrite?")
        _ = singleSelection(on: sut, items: items)
        _ = multiSelection(on: sut, items: items)

        #expect(sut.capturedPrompts == ["Enter name"])
        #expect(sut.capturedPermissionPrompts == ["Overwrite?"])
        #expect(sut.capturedSingleSelectionPrompts == ["Pick one"])
        #expect(sut.capturedMultiSelectionPrompts == ["Pick many"])
    }
}


// MARK: - Helpers
private extension ScriptedPickerTests {
    func singleSelection(on sut: MockSwiftPicker, items: [String]) -> String? {
        return sut.singleSelection(
            prompt: "Pick one",
            items: items,
            layout: .singleColumn,
            newScreen: false,
            showSelectedItemText: false
        )
    }

    func makeTreeItems(names: [String]) -> [TreeTestItem] {
        return names.map {
            TestFactory.makeTreeItem(name: $0, children: [], hasChildren: false, metadata: nil, isSelectable: true)
        }
    }

    func treeNavigation(on sut: MockSwiftPicker, items: [TreeTestItem]) -> TreeTestItem? {
        return sut.treeNavigation(
            prompt: "Pick folder",
            root: .init(displayName: "Root", children: items),
            showPromptText: true,
            showSelectedItemText: true
        )
    }

    func multiSelection(on sut: MockSwiftPicker, items: [String]) -> [String] {
        return sut.multiSelection(
            prompt: "Pick many",
            items: items,
            layout: .singleColumn,
            newScreen: false,
            showSelectedItemText: false
        )
    }
}

// MARK: - SUT
private extension ScriptedPickerTests {
    func makeSUT(
        permissions: [Bool] = [],
        singles: [MockSingleSelectionOutcome] = [],
        multis: [MockMultiSelectionOutcome] = [],
        inputs: [String] = [],
        treeNavigations: [MockTreeSelectionOutcome] = []
    ) -> MockSwiftPicker {
        return ScriptedPicker.make(
            permissions: permissions,
            singles: singles,
            multis: multis,
            inputs: inputs,
            treeNavigations: treeNavigations
        )
    }
}
