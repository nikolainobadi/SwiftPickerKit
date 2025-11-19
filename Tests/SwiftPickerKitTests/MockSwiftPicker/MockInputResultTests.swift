//
//  MockInputResultTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerTesting

struct MockInputResultTests {
    @Test("Creates empty configuration by default")
    func createsEmptyConfigurationByDefault() {
        let sut = makeSUT()

        #expect(sut.defaultValue.isEmpty)

        if case .ordered(let responses) = sut.type {
            #expect(responses.isEmpty)
        } else {
            Issue.record("Expected ordered type with empty array")
        }
    }

    @Test("Accepts custom default value")
    func acceptsCustomDefaultValue() {
        let customDefault = "fallback response"
        let sut = makeSUT(defaultValue: customDefault)

        #expect(sut.defaultValue == customDefault)
    }

    @Test("Stores ordered response configuration")
    func storesOrderedResponseConfiguration() {
        let responses = ["first", "second", "third"]
        let sut = makeSUT(type: .ordered(responses))

        if case .ordered(let storedResponses) = sut.type {
            #expect(storedResponses == responses)
        } else {
            Issue.record("Expected ordered type")
        }
    }

    @Test("Stores dictionary response configuration")
    func storesDictionaryResponseConfiguration() {
        let mapping = ["greeting": "hello", "farewell": "goodbye"]
        let sut = makeSUT(type: .dictionary(mapping))

        if case .dictionary(let storedMapping) = sut.type {
            #expect(storedMapping == mapping)
        } else {
            Issue.record("Expected dictionary type")
        }
    }
}


// MARK: - Sequential Response Tests
extension MockInputResultTests {
    @Test("Provides responses in order until exhausted")
    func providesResponsesInOrderUntilExhausted() {
        let responses = ["first", "second", "third"]
        var sut = makeSUT(type: .ordered(responses))

        let firstResponse = sut.nextResponse(for: "any prompt")
        #expect(firstResponse == responses[0])

        let secondResponse = sut.nextResponse(for: "another prompt")
        #expect(secondResponse == responses[1])

        let thirdResponse = sut.nextResponse(for: "third prompt")
        #expect(thirdResponse == responses[2])
    }

    @Test("Falls back to default value after responses exhausted")
    func fallsBackToDefaultValueAfterResponsesExhausted() {
        let defaultValue = "fallback"
        let singleResponse = "only one"
        var sut = makeSUT(defaultValue: defaultValue, type: .ordered([singleResponse]))

        let firstResponse = sut.nextResponse(for: "prompt")
        #expect(firstResponse == singleResponse)

        let secondResponse = sut.nextResponse(for: "prompt")
        #expect(secondResponse == defaultValue)

        let thirdResponse = sut.nextResponse(for: "prompt")
        #expect(thirdResponse == defaultValue)
    }

    @Test("Returns default immediately when no responses configured")
    func returnsDefaultImmediatelyWhenNoResponsesConfigured() {
        let defaultValue = "fallback"
        var sut = makeSUT(defaultValue: defaultValue, type: .ordered([]))

        let response = sut.nextResponse(for: "any prompt")
        #expect(response == defaultValue)
    }

    @Test("Removes used responses from available pool")
    func removesUsedResponsesFromAvailablePool() {
        let initialResponses = ["first", "second", "third"]
        var sut = makeSUT(type: .ordered(initialResponses))

        _ = sut.nextResponse(for: "prompt")

        if case .ordered(let remaining) = sut.type {
            #expect(remaining.count == 2)
            #expect(remaining == ["second", "third"])
        } else {
            Issue.record("Expected ordered type after first call")
        }

        _ = sut.nextResponse(for: "prompt")

        if case .ordered(let remaining) = sut.type {
            #expect(remaining.count == 1)
            #expect(remaining == ["third"])
        } else {
            Issue.record("Expected ordered type after second call")
        }

        _ = sut.nextResponse(for: "prompt")

        if case .ordered(let remaining) = sut.type {
            #expect(remaining.isEmpty)
        } else {
            Issue.record("Expected ordered type with empty array")
        }
    }

    @Test("Ignores prompt text when providing sequential responses")
    func ignoresPromptTextWhenProvidingSequentialResponses() {
        let response = "response"
        let defaultValue = "default"
        var sut = makeSUT(defaultValue: defaultValue, type: .ordered([response]))

        let firstResponse = sut.nextResponse(for: "any prompt")
        let secondResponse = sut.nextResponse(for: "completely different prompt")

        #expect(firstResponse == response)
        #expect(secondResponse == defaultValue)
    }
}


// MARK: - Prompt-Mapped Response Tests
extension MockInputResultTests {
    @Test("Returns response matching prompt key")
    func returnsResponseMatchingPromptKey() {
        let greetingPrompt = "greeting"
        let farewellPrompt = "farewell"
        let greetingResponse = "hello"
        let farewellResponse = "goodbye"

        var sut = makeSUT(type: .dictionary([
            greetingPrompt: greetingResponse,
            farewellPrompt: farewellResponse
        ]))

        let actualGreeting = sut.nextResponse(for: greetingPrompt)
        #expect(actualGreeting == greetingResponse)

        let actualFarewell = sut.nextResponse(for: farewellPrompt)
        #expect(actualFarewell == farewellResponse)
    }

    @Test("Falls back to default value for unknown prompts")
    func fallsBackToDefaultValueForUnknownPrompts() {
        let defaultValue = "unknown"
        let knownPrompt = "known"
        let unknownPrompt = "unknown prompt"

        var sut = makeSUT(defaultValue: defaultValue, type: .dictionary([knownPrompt: "response"]))

        let response = sut.nextResponse(for: unknownPrompt)
        #expect(response == defaultValue)
    }

    @Test("Returns consistent response for repeated prompts")
    func returnsConsistentResponseForRepeatedPrompts() {
        let prompt = "repeat"
        let response = "same"
        var sut = makeSUT(type: .dictionary([prompt: response]))

        let first = sut.nextResponse(for: prompt)
        let second = sut.nextResponse(for: prompt)
        let third = sut.nextResponse(for: prompt)

        #expect(first == response)
        #expect(second == response)
        #expect(third == response)
    }

    @Test("Preserves all mappings across multiple queries")
    func preservesAllMappingsAcrossMultipleQueries() {
        let prompt = "key"
        let response = "value"
        var sut = makeSUT(type: .dictionary([prompt: response]))

        _ = sut.nextResponse(for: prompt)
        _ = sut.nextResponse(for: prompt)

        if case .dictionary(let mapping) = sut.type {
            #expect(mapping[prompt] == response)
            #expect(mapping.count == 1)
        } else {
            Issue.record("Expected dictionary type to remain unchanged")
        }
    }

    @Test("Returns empty string for unknown prompts when default is empty")
    func returnsEmptyStringForUnknownPromptsWhenDefaultIsEmpty() {
        let unknownPrompt = "missing"
        var sut = makeSUT(defaultValue: "", type: .dictionary(["key": "value"]))

        let response = sut.nextResponse(for: unknownPrompt)
        #expect(response.isEmpty)
    }

    @Test("Distinguishes prompts by exact case match")
    func distinguishesPromptsByExactCaseMatch() {
        let uppercasePrompt = "Prompt"
        let lowercasePrompt = "prompt"
        let response = "uppercase"

        var sut = makeSUT(type: .dictionary([uppercasePrompt: response]))

        let uppercaseResponse = sut.nextResponse(for: uppercasePrompt)
        let lowercaseResponse = sut.nextResponse(for: lowercasePrompt)

        #expect(uppercaseResponse == response)
        #expect(lowercaseResponse.isEmpty)
    }
}


// MARK: - SUT
private extension MockInputResultTests {
    func makeSUT(defaultValue: String = "", type: MockInputType = .ordered([])) -> MockInputResult {
        return .init(defaultValue: defaultValue, type: type)
    }
}
