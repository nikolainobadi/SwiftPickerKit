//
//  PickerTextFormatterTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct PickerTextFormatterTests {
    @Test
    func `Centers text with equal padding on both sides`() {
        let sut = makeSUT()

        #expect(sut.centerText("Hello", inWidth: 11) == "   Hello")
    }

    @Test
    func `Returns text without padding when width matches text length`() {
        let sut = makeSUT()
        let text = "Swift"

        #expect(sut.centerText(text, inWidth: text.count) == text)
    }

    @Test
    func `Returns text without padding when width is smaller than text`() {
        let sut = makeSUT()
        let text = "LongText"

        #expect(sut.centerText(text, inWidth: 4) == text)
    }

    @Test
    func `Handles empty text with width-based padding`() {
        let sut = makeSUT()

        #expect(sut.centerText("", inWidth: 6) == "   ")
    }

    @Test
    func `Returns text as-is when width is zero`() {
        let sut = makeSUT()
        let text = "Test"

        #expect(sut.centerText(text, inWidth: 0) == text)
    }
}


// MARK: - Truncation
extension PickerTextFormatterTests {
    @Test
    func `Returns original text when shorter than maximum width`() {
        let sut = makeSUT()
        let text = "Short"

        #expect(sut.truncate(text, maxWidth: 10) == text)
    }

    @Test
    func `Returns original text when equal to maximum width`() {
        let sut = makeSUT()
        let text = "Exact"

        #expect(sut.truncate(text, maxWidth: text.count) == text)
    }

    @Test
    func `Truncates text with ellipsis when exceeding maximum width`() {
        let sut = makeSUT()

        #expect(sut.truncate("This is a very long text", maxWidth: 10) == "This is a…")
    }

    @Test
    func `Returns empty string when maximum width is one`() {
        let sut = makeSUT()

        #expect(sut.truncate("Any text", maxWidth: 1) == "")
    }

    @Test
    func `Returns empty string when maximum width is zero`() {
        let sut = makeSUT()

        #expect(sut.truncate("Test", maxWidth: 0) == "")
    }

    @Test
    func `Returns empty text unchanged regardless of maximum width`() {
        let sut = makeSUT()

        #expect(sut.truncate("", maxWidth: 5) == "")
    }

    @Test
    func `Preserves single character when truncating to width of two`() {
        let sut = makeSUT()

        #expect(sut.truncate("Hello", maxWidth: 2) == "H…")
    }
}


// MARK: - SUT
private extension PickerTextFormatterTests {
    func makeSUT() -> PickerTextFormatter.Type {
        return PickerTextFormatter.self
    }
}
