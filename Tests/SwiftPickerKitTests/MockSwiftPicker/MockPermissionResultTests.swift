//
//  MockPermissionResultTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerTesting

struct MockPermissionResultTests {
    @Test("Creates disabled configuration by default")
    func createsDisabledConfigurationByDefault() {
        let sut = makeSUT()

        #expect(sut.defaultValue == false)

        if case .ordered(let responses) = sut.type {
            #expect(responses.isEmpty)
        } else {
            Issue.record("Expected ordered type with empty array")
        }
    }

    @Test("Accepts custom default value")
    func acceptsCustomDefaultValue() {
        let sut = makeSUT(defaultValue: true)

        #expect(sut.defaultValue == true)
    }

    @Test("Stores ordered response configuration")
    func storesOrderedResponseConfiguration() {
        let responses = [true, false, true]
        let sut = makeSUT(type: .ordered(responses))

        if case .ordered(let storedResponses) = sut.type {
            #expect(storedResponses == responses)
        } else {
            Issue.record("Expected ordered type")
        }
    }

    @Test("Stores dictionary response configuration")
    func storesDictionaryResponseConfiguration() {
        let mapping = ["prompt": true]
        let sut = makeSUT(type: .dictionary(mapping))

        if case .dictionary(let storedMapping) = sut.type {
            #expect(storedMapping == mapping)
        } else {
            Issue.record("Expected dictionary type")
        }
    }
}


// MARK: - Sequential Response Tests
extension MockPermissionResultTests {
    @Test("Provides boolean responses in order until exhausted")
    func providesBooleanResponsesInOrderUntilExhausted() {
        let responses = [true, false, false]
        var sut = makeSUT(type: .ordered(responses))

        #expect(sut.nextResponse(for: "prompt") == true)
        #expect(sut.nextResponse(for: "prompt") == false)
        #expect(sut.nextResponse(for: "prompt") == false)
    }

    @Test("Falls back to default after responses exhausted")
    func fallsBackToDefaultAfterResponsesExhausted() {
        var sut = makeSUT(defaultValue: true, type: .ordered([false]))

        #expect(sut.nextResponse(for: "prompt") == false)
        #expect(sut.nextResponse(for: "prompt") == true)
    }

    @Test("Returns default immediately when no responses configured")
    func returnsDefaultImmediatelyWhenNoResponsesConfigured() {
        var sut = makeSUT(defaultValue: true)

        #expect(sut.nextResponse(for: "prompt") == true)
    }

    @Test("Removes used responses from available pool")
    func removesUsedResponsesFromAvailablePool() {
        var sut = makeSUT(type: .ordered([true, false]))

        _ = sut.nextResponse(for: "prompt")
        if case .ordered(let remainingAfterFirst) = sut.type {
            #expect(remainingAfterFirst == [false])
        } else {
            Issue.record("Expected ordered type after first call")
        }

        _ = sut.nextResponse(for: "prompt")
        if case .ordered(let remainingAfterSecond) = sut.type {
            #expect(remainingAfterSecond.isEmpty)
        } else {
            Issue.record("Expected ordered type after second call")
        }
    }

    @Test("Ignores prompt text when sequential responses configured")
    func ignoresPromptTextWhenSequentialResponsesConfigured() {
        var sut = makeSUT(defaultValue: false, type: .ordered([true]))

        let first = sut.nextResponse(for: "prompt one")
        let second = sut.nextResponse(for: "prompt two")

        #expect(first == true)
        #expect(second == false)
    }
}


// MARK: - Prompt-Mapped Response Tests
extension MockPermissionResultTests {
    @Test("Returns response matching mapped prompt key")
    func returnsResponseMatchingMappedPromptKey() {
        var sut = makeSUT(type: .dictionary(["allow?": true, "deny?": false]))

        #expect(sut.nextResponse(for: "allow?") == true)
        #expect(sut.nextResponse(for: "deny?") == false)
    }

    @Test("Falls back to default for unknown prompts")
    func fallsBackToDefaultForUnknownPrompts() {
        var sut = makeSUT(defaultValue: true, type: .dictionary(["known": false]))

        #expect(sut.nextResponse(for: "unknown") == true)
    }

    @Test("Returns consistent response for repeated prompts")
    func returnsConsistentResponseForRepeatedPrompts() {
        var sut = makeSUT(type: .dictionary(["repeat": true]))

        #expect(sut.nextResponse(for: "repeat") == true)
        #expect(sut.nextResponse(for: "repeat") == true)
    }

    @Test("Preserves mapping across multiple queries")
    func preservesMappingAcrossMultipleQueries() {
        var sut = makeSUT(type: .dictionary(["key": true]))

        _ = sut.nextResponse(for: "key")
        _ = sut.nextResponse(for: "key")

        if case .dictionary(let mapping) = sut.type {
            #expect(mapping["key"] == true)
            #expect(mapping.count == 1)
        } else {
            Issue.record("Expected dictionary type to remain unchanged")
        }
    }

    @Test("Returns false for unknown prompts when default is false")
    func returnsFalseForUnknownPromptsWhenDefaultIsFalse() {
        var sut = makeSUT(defaultValue: false, type: .dictionary(["key": true]))

        #expect(sut.nextResponse(for: "missing") == false)
    }

    @Test("Distinguishes prompts by exact case")
    func distinguishesPromptsByExactCase() {
        var sut = makeSUT(type: .dictionary(["Prompt": true]))

        #expect(sut.nextResponse(for: "Prompt") == true)
        #expect(sut.nextResponse(for: "prompt") == false)
    }
}


// MARK: - SUT
private extension MockPermissionResultTests {
    func makeSUT(defaultValue: Bool = false, type: MockPermissionType = .ordered([])) -> MockPermissionResult {
        return .init(defaultValue: defaultValue, type: type)
    }
}
