//
//  MockSelectionResultTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerTesting

struct MockSelectionResultTests {
    @Test
    func `Creates empty configuration by default`() {
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

    @Test
    func `Accepts custom defaults`() {
        let defaultSingle = MockSingleSelectionOutcome.index(2)
        let defaultMulti = MockMultiSelectionOutcome.indices([0, 3])
        let sut = makeSUT(defaultSingle: defaultSingle, defaultMulti: defaultMulti)

        #expect(sut.defaultSingle == defaultSingle)
        #expect(sut.defaultMulti == defaultMulti)
    }

    @Test
    func `Stores ordered single selection responses`() {
        let responses: [MockSingleSelectionOutcome] = [.index(1), .index(3)]
        let sut = makeSUT(singleType: .ordered(responses))

        if case .ordered(let stored) = sut.singleType {
            #expect(stored == responses)
        } else {
            Issue.record("Expected ordered single sequence")
        }
    }

    @Test
    func `Stores ordered multi selection responses`() {
        let responses: [MockMultiSelectionOutcome] = [.indices([0]), .indices([1, 2])]
        let sut = makeSUT(multiType: .ordered(responses))

        if case .ordered(let stored) = sut.multiType {
            #expect(stored == responses)
        } else {
            Issue.record("Expected ordered multi sequence")
        }
    }

    @Test
    func `Stores dictionary single selection responses`() {
        let mapping = ["prompt": MockSingleSelectionOutcome.index(0)]
        let sut = makeSUT(singleType: .dictionary(mapping))

        if case .dictionary(let stored) = sut.singleType {
            #expect(stored == mapping)
        } else {
            Issue.record("Expected dictionary single sequence")
        }
    }

    @Test
    func `Stores dictionary multi selection responses`() {
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
    @Test
    func `Provides single responses in order until exhausted`() {
        let responses: [MockSingleSelectionOutcome] = [.index(0), .none]
        var sut = makeSUT(singleType: .ordered(responses))

        let first = sut.nextSingleOutcome(for: "prompt")
        let second = sut.nextSingleOutcome(for: "prompt")
        let third = sut.nextSingleOutcome(for: "prompt")

        #expect(first == responses[0])
        #expect(second == responses[1])
        #expect(third == .none)
    }

    @Test
    func `Provides multi responses in order until exhausted`() {
        let responses: [MockMultiSelectionOutcome] = [.indices([0]), .indices([1, 2])]
        var sut = makeSUT(multiType: .ordered(responses))

        let first = sut.nextMultiOutcome(for: "prompt")
        let second = sut.nextMultiOutcome(for: "prompt")
        let third = sut.nextMultiOutcome(for: "prompt")

        #expect(first == responses[0])
        #expect(second == responses[1])
        #expect(third == .none)
    }

    @Test
    func `Ignores prompt text when using ordered responses`() {
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
    @Test
    func `Returns prompt specific single responses`() {
        let mapping = [
            "first": MockSingleSelectionOutcome.index(0),
            "second": MockSingleSelectionOutcome.index(1)
        ]
        var sut = makeSUT(singleType: .dictionary(mapping))

        #expect(sut.nextSingleOutcome(for: "first") == mapping["first"])
        #expect(sut.nextSingleOutcome(for: "second") == mapping["second"])
    }

    @Test
    func `Returns prompt specific multi responses`() {
        let mapping = [
            "first": MockMultiSelectionOutcome.indices([0]),
            "second": MockMultiSelectionOutcome.indices([1, 2])
        ]
        var sut = makeSUT(multiType: .dictionary(mapping))

        #expect(sut.nextMultiOutcome(for: "first") == mapping["first"])
        #expect(sut.nextMultiOutcome(for: "second") == mapping["second"])
    }

    @Test
    func `Falls back to defaults for unknown prompts`() {
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
