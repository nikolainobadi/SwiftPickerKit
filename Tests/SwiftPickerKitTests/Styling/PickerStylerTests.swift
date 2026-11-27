import Testing
@testable import SwiftPickerKit

struct PickerStylerTests {
    @Test
    func `Combines attributes and color into one escape sequence`() {
        let sut = makeSUT(colorEnabled: true)
        let style = PickerTextStyle(color: .red, isBold: true, isDim: true, isUnderlined: true)

        #expect(sut.styled("Text", as: style) == "\u{1B}[1;2;4;31mText\u{1B}[0m")
    }

    @Test
    func `Uses 256-color codes for palette colors`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.styled("Text", color: .palette(250)) == "\u{1B}[38;5;250mText\u{1B}[0m")
    }

    @Test
    func `Returns empty text unchanged`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.styled("", as: .failure) == "")
    }

    @Test
    func `Returns text unchanged when there is nothing to apply`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.styled("Text", color: nil) == "Text")
    }

    @Test
    func `Drops color but keeps underline when color is disabled`() {
        let sut = makeSUT(colorEnabled: false)
        let style = PickerTextStyle(color: .red, isBold: false, isDim: false, isUnderlined: true)

        #expect(sut.styled("Text", as: style) == "\u{1B}[4mText\u{1B}[0m")
    }

    @Test
    func `Returns color-only text unchanged when color is disabled`() {
        let sut = makeSUT(colorEnabled: false)

        #expect(sut.styled("Text", color: .green) == "Text")
    }
}

// MARK: - SUT
private extension PickerStylerTests {
    func makeSUT(colorEnabled: Bool) -> PickerStyler {
        return PickerStyler(colorEnabled: colorEnabled)
    }
}
