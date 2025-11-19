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


// MARK: - SUT
private extension MockSwiftPickerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init()
    ) -> MockSwiftPicker {
        return .init(inputResult: inputResult, permissionResult: permissionResult)
    }
}
