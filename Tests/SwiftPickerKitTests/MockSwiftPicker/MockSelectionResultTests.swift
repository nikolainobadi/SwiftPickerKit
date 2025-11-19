//
//  MockSelectionResultTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerTesting

struct MockSelectionResultTests {
    @Test("Creates empty configuration by default")
    func createsEmptyConfigurationByDefault() {
        let sut = makeSUT()

        #expect(sut.defaultSingle == .none)
        #expect(sut.defaultMulti == .none)

        if case .ordered(let singles) = sut.singleType {
            #expect(singles.isEmpty)
        } else {
            Issue.record("Expected ordered single configuration")
        }

        if case .ordered(let multi) = sut.multiType {
            #expect(multi.isEmpty)
        } else {
            Issue.record("Expected ordered multi configuration")
        }
    }

    @Test("Accepts custom defaults")
    func acceptsCustomDefaults() {
        let defaultSingle = MockSingleSelectionOutcome.index(2)
        let defaultMulti = MockMultiSelectionOutcome.indices([0, 3])
        let sut = makeSUT(defaultSingle: defaultSingle, defaultMulti: defaultMulti)

        #expect(sut.defaultSingle == defaultSingle)
        #expect(sut.defaultMulti == defaultMulti)
    }

    @Test("Stores ordered single selection responses")
    func storesOrderedSingleSelectionResponses() {
        let responses: [MockSingleSelectionOutcome] = [.index(1), .index(3)]
        let sut = makeSUT(singleType: .ordered(responses))

        if case .ordered(let stored) = sut.singleType {
            #expect(stored == responses)
        } else {
            Issue.record("Expected ordered single sequence")
        }
    }

    @Test("Stores ordered multi selection responses")
    func storesOrderedMultiSelectionResponses() {
        let responses: [MockMultiSelectionOutcome] = [.indices([0]), .indices([1, 2])]
        let sut = makeSUT(multiType: .ordered(responses))

        if case .ordered(let stored) = sut.multiType {
            #expect(stored == responses)
        } else {
            Issue.record("Expected ordered multi sequence")
        }
    }

    @Test("Stores dictionary single selection responses")
    func storesDictionarySingleSelectionResponses() {
        let mapping = ["prompt": MockSingleSelectionOutcome.index(0)]
        let sut = makeSUT(singleType: .dictionary(mapping))

        if case .dictionary(let stored) = sut.singleType {
            #expect(stored == mapping)
        } else {
            Issue.record("Expected dictionary single sequence")
        }
    }

    @Test("Stores dictionary multi selection responses")
    func storesDictionaryMultiSelectionResponses() {
        let mapping = ["prompt": MockMultiSelectionOutcome.indices([1])]
        let sut = makeSUT(multiType: .dictionary(mapping))

        if case .dictionary(let stored) = sut.multiType {
            #expect(stored == mapping)
        } else {
            Issue.record("Expected dictionary multi sequence")
        }
    }
}


// MARK: - Sequential Access Tests
extension MockSelectionResultTests {
    @Test("Provides single responses in order until exhausted")
    func providesSingleResponsesInOrderUntilExhausted() {
        let responses: [MockSingleSelectionOutcome] = [.index(0), .none]
        var sut = makeSUT(singleType: .ordered(responses))

        let first = sut.nextSingleOutcome(for: "prompt")
        let second = sut.nextSingleOutcome(for: "prompt")
        let third = sut.nextSingleOutcome(for: "prompt")

        #expect(first == responses[0])
        #expect(second == responses[1])
        #expect(third == .none)
    }

    @Test("Provides multi responses in order until exhausted")
    func providesMultiResponsesInOrderUntilExhausted() {
        let responses: [MockMultiSelectionOutcome] = [.indices([0]), .indices([1, 2])]
        var sut = makeSUT(multiType: .ordered(responses))

        let first = sut.nextMultiOutcome(for: "prompt")
        let second = sut.nextMultiOutcome(for: "prompt")
        let third = sut.nextMultiOutcome(for: "prompt")

        #expect(first == responses[0])
        #expect(second == responses[1])
        #expect(third == .none)
    }

    @Test("Ignores prompt text when using ordered responses")
    func ignoresPromptTextWhenUsingOrderedResponses() {
        let response = MockSingleSelectionOutcome.index(1)
        var sut = makeSUT(singleType: .ordered([response]))

        let first = sut.nextSingleOutcome(for: "first")
        let second = sut.nextSingleOutcome(for: "second")

        #expect(first == response)
        #expect(second == .none)
    }
}


// MARK: - Dictionary Access Tests
extension MockSelectionResultTests {
    @Test("Returns prompt specific single responses")
    func returnsPromptSpecificSingleResponses() {
        let mapping = [
            "first": MockSingleSelectionOutcome.index(0),
            "second": MockSingleSelectionOutcome.index(1)
        ]
        var sut = makeSUT(singleType: .dictionary(mapping))

        #expect(sut.nextSingleOutcome(for: "first") == mapping["first"])
        #expect(sut.nextSingleOutcome(for: "second") == mapping["second"])
    }

    @Test("Returns prompt specific multi responses")
    func returnsPromptSpecificMultiResponses() {
        let mapping = [
            "first": MockMultiSelectionOutcome.indices([0]),
            "second": MockMultiSelectionOutcome.indices([1, 2])
        ]
        var sut = makeSUT(multiType: .dictionary(mapping))

        #expect(sut.nextMultiOutcome(for: "first") == mapping["first"])
        #expect(sut.nextMultiOutcome(for: "second") == mapping["second"])
    }

    @Test("Falls back to defaults for unknown prompts")
    func fallsBackToDefaultsForUnknownPrompts() {
        let defaultSingle = MockSingleSelectionOutcome.index(2)
        let defaultMulti = MockMultiSelectionOutcome.indices([0, 1])
        var sut = makeSUT(
            defaultSingle: defaultSingle,
            defaultMulti: defaultMulti,
            singleType: .dictionary([:]),
            multiType: .dictionary([:])
        )

        #expect(sut.nextSingleOutcome(for: "unknown") == defaultSingle)
        #expect(sut.nextMultiOutcome(for: "unknown") == defaultMulti)
    }
}


// MARK: - SUT
private extension MockSelectionResultTests {
    func makeSUT(
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
}
