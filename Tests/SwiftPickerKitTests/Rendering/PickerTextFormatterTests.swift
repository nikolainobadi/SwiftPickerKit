//
//  PickerTextFormatterTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct PickerTextFormatterTests {
    @Test("Centers text with equal padding on both sides")
    func centersTextWithEqualPaddingOnBothSides() {
        let text = "Hello"
        let width = 11

        let result = PickerTextFormatter.centerText(text, inWidth: width)

        #expect(result == "   Hello")
        #expect(result.count == 8)
    }

    @Test("Returns text without padding when width matches text length")
    func returnsTextWithoutPaddingWhenWidthMatchesTextLength() {
        let text = "Swift"

        let result = PickerTextFormatter.centerText(text, inWidth: text.count)

        #expect(result == text)
    }

    @Test("Returns text without padding when width is smaller than text")
    func returnsTextWithoutPaddingWhenWidthIsSmallerThanText() {
        let text = "LongText"
        let width = 4

        let result = PickerTextFormatter.centerText(text, inWidth: width)

        #expect(result == text)
    }

    @Test("Handles empty text with width-based padding")
    func handlesEmptyTextWithWidthBasedPadding() {
        let text = ""
        let width = 6

        let result = PickerTextFormatter.centerText(text, inWidth: width)

        #expect(result == "   ")
        #expect(result.count == 3)
    }

    @Test("Returns text as-is when width is zero")
    func returnsTextAsIsWhenWidthIsZero() {
        let text = "Test"

        let result = PickerTextFormatter.centerText(text, inWidth: 0)

        #expect(result == text)
    }

    @Test("Returns original text when shorter than maximum width")
    func returnsOriginalTextWhenShorterThanMaximumWidth() {
        let text = "Short"
        let maxWidth = 10

        let result = PickerTextFormatter.truncate(text, maxWidth: maxWidth)

        #expect(result == text)
    }

    @Test("Returns original text when equal to maximum width")
    func returnsOriginalTextWhenEqualToMaximumWidth() {
        let text = "Exact"

        let result = PickerTextFormatter.truncate(text, maxWidth: text.count)

        #expect(result == text)
    }

    @Test("Truncates text with ellipsis when exceeding maximum width")
    func truncatesTextWithEllipsisWhenExceedingMaximumWidth() {
        let text = "This is a very long text"
        let maxWidth = 10

        let result = PickerTextFormatter.truncate(text, maxWidth: maxWidth)

        #expect(result == "This is a…")
        #expect(result.count == maxWidth)
    }

    @Test("Returns empty string when maximum width is one")
    func returnsEmptyStringWhenMaximumWidthIsOne() {
        let text = "Any text"

        let result = PickerTextFormatter.truncate(text, maxWidth: 1)

        #expect(result == "")
    }

    @Test("Returns empty string when maximum width is zero")
    func returnsEmptyStringWhenMaximumWidthIsZero() {
        let text = "Test"

        let result = PickerTextFormatter.truncate(text, maxWidth: 0)

        #expect(result == "")
    }

    @Test("Returns empty text unchanged regardless of maximum width")
    func returnsEmptyTextUnchangedRegardlessOfMaximumWidth() {
        let text = ""
        let maxWidth = 5

        let result = PickerTextFormatter.truncate(text, maxWidth: maxWidth)

        #expect(result == "")
    }

    @Test("Preserves single character when truncating to width of two")
    func preservesSingleCharacterWhenTruncatingToWidthOfTwo() {
        let text = "Hello"
        let maxWidth = 2

        let result = PickerTextFormatter.truncate(text, maxWidth: maxWidth)

        #expect(result == "H…")
        #expect(result.count == maxWidth)
    }
}
