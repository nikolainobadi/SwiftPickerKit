//
//  MockTreeNavigationResultTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerTesting

struct MockTreeNavigationResultTests {
    @Test
    func `Creates empty configuration by default`() {
        let sut = makeSUT()

        #expect(sut.defaultOutcome == .none)

        if case .ordered(let responses) = sut.type {
            #expect(responses.isEmpty)
        } else {
            Issue.record("Expected ordered configuration")
        }
    }

    @Test
    func `Accepts custom default outcome`() {
        let outcome = MockTreeSelectionOutcome.index(1)
        let sut = makeSUT(defaultOutcome: outcome)

        #expect(sut.defaultOutcome == outcome)
    }

    @Test
    func `Stores ordered responses`() {
        let responses: [MockTreeSelectionOutcome] = [.index(0), .index(2)]
        let sut = makeSUT(type: .ordered(responses))

        if case .ordered(let stored) = sut.type {
            #expect(stored == responses)
        } else {
            Issue.record("Expected ordered configuration")
        }
    }

    @Test
    func `Stores dictionary responses`() {
        let mapping = ["prompt": MockTreeSelectionOutcome.index(3)]
        let sut = makeSUT(type: .dictionary(mapping))

        if case .dictionary(let stored) = sut.type {
            #expect(stored == mapping)
        } else {
            Issue.record("Expected dictionary configuration")
        }
    }
}


// MARK: - Sequential Access
extension MockTreeNavigationResultTests {
    @Test
    func `Provides outcomes in order until exhausted`() {
        let responses: [MockTreeSelectionOutcome] = [.index(0), .index(1)]
        var sut = makeSUT(type: .ordered(responses))

        #expect(sut.nextOutcome(for: "prompt") == responses[0])
        #expect(sut.nextOutcome(for: "prompt") == responses[1])
        #expect(sut.nextOutcome(for: "prompt") == .none)
    }

    @Test
    func `Ignores prompt text for ordered responses`() {
        let response = MockTreeSelectionOutcome.index(0)
        var sut = makeSUT(type: .ordered([response]))

        let first = sut.nextOutcome(for: "one")
        let second = sut.nextOutcome(for: "two")

        #expect(first == response)
        #expect(second == .none)
    }
}


// MARK: - Dictionary Access
extension MockTreeNavigationResultTests {
    @Test
    func `Returns prompt specific outcomes`() {
        let mapping = ["first": MockTreeSelectionOutcome.index(0), "second": .index(2)]
        var sut = makeSUT(type: .dictionary(mapping))

        #expect(sut.nextOutcome(for: "first") == mapping["first"])
        #expect(sut.nextOutcome(for: "second") == mapping["second"])
    }

    @Test
    func `Falls back to default when prompt missing`() {
        let defaultOutcome = MockTreeSelectionOutcome.index(3)
        var sut = makeSUT(defaultOutcome: defaultOutcome, type: .dictionary([:]))

        #expect(sut.nextOutcome(for: "unknown") == defaultOutcome)
    }
}


// MARK: - SUT
private extension MockTreeNavigationResultTests {
    func makeSUT(
        defaultOutcome: MockTreeSelectionOutcome = .none,
        type: MockTreeSelectionType = .ordered([])
    ) -> MockTreeNavigationResult {
        return .init(defaultOutcome: defaultOutcome, type: type)
    }
}
