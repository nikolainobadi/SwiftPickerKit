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
    @Test
    func `Ignores escape sequences when measuring visible width`() {
        let sut = makeSUT()

        #expect(sut.visibleWidth("\u{1B}[38;5;250mHello\u{1B}[0m") == 5)
    }

    @Test
    func `Returns styled text unchanged when its visible width fits`() {
        let sut = makeSUT()
        let styled = "\u{1B}[31mHello\u{1B}[0m"

        #expect(sut.truncate(styled, maxWidth: 5) == styled)
    }

    @Test
    func `Keeps escape sequences whole and appends a reset when cutting styled text`() {
        let sut = makeSUT()

        #expect(sut.truncate("\u{1B}[94mHello World\u{1B}[0m", maxWidth: 6) == "\u{1B}[94mHello\u{1B}[0m…\u{1B}[0m")
    }

    @Test
    func `Centers styled text by its visible width`() {
        let sut = makeSUT()
        let styled = "\u{1B}[31mHello\u{1B}[0m"

        #expect(sut.centerText(styled, inWidth: 11) == "   " + styled)
    }
}

// MARK: - Segment Truncation
extension PickerTextFormatterTests {
    @Test
    func `Returns segments unchanged when they fit`() {
        let sut = makeSUT()
        let segments = [PickerTextSegment(text: "ab", style: nil), PickerTextSegment(text: "cd", style: .failure)]

        #expect(sut.truncate(segments, maxWidth: 4) == segments)
    }

    @Test
    func `Cuts across segments and ends the cut segment with an ellipsis in its style`() {
        let sut = makeSUT()
        let segments = [PickerTextSegment(text: "abc", style: nil), PickerTextSegment(text: "defgh", style: .failure), PickerTextSegment(text: "ij", style: .success)]

        #expect(sut.truncate(segments, maxWidth: 6) == [PickerTextSegment(text: "abc", style: nil), PickerTextSegment(text: "de…", style: .failure)])
    }

    @Test
    func `Puts the ellipsis on the next segment when the cut falls on a boundary`() {
        let sut = makeSUT()
        let segments = [PickerTextSegment(text: "abc", style: nil), PickerTextSegment(text: "def", style: .failure)]

        #expect(sut.truncate(segments, maxWidth: 4) == [PickerTextSegment(text: "abc", style: nil), PickerTextSegment(text: "…", style: .failure)])
    }

    @Test
    func `Returns no segments when truncation is needed but the width is one or less`() {
        let sut = makeSUT()

        #expect(sut.truncate([PickerTextSegment(text: "abc", style: nil)], maxWidth: 1).isEmpty)
    }
}

// MARK: - SUT
private extension PickerTextFormatterTests {
    func makeSUT() -> PickerTextFormatter.Type {
        return PickerTextFormatter.self
    }
}
