import Testing
@testable import SwiftPickerKit

struct OptionRowFormatterTests {
    @Test
    func `Fills the marker for the active row in single selection`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.marker(isActive: true, isSelected: false, isSingleSelection: true) == "\u{1B}[92m●\u{1B}[0m")
    }

    @Test
    func `Fills the marker for a selected row in multi-selection`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.marker(isActive: false, isSelected: true, isSingleSelection: false) == "\u{1B}[92m●\u{1B}[0m")
    }

    @Test
    func `Draws a hollow gray marker otherwise`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.marker(isActive: true, isSelected: false, isSingleSelection: false) == "\u{1B}[38;5;250m○\u{1B}[0m")
    }

    @Test
    func `Draws unstyled inactive rows in the theme's inactive text color`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.title(for: TestItem(name: "Plain"), isActive: false, maxWidth: 20) == "\u{1B}[38;5;250mPlain\u{1B}[0m")
    }

    @Test
    func `Draws styled inactive rows in the item's style`() {
        let sut = makeSUT(colorEnabled: true)
        let item = StyledTestItem(name: "Failed", displayStyle: .failure)

        #expect(sut.title(for: item, isActive: false, maxWidth: 20) == "\u{1B}[1;31mFailed\u{1B}[0m")
    }

    @Test
    func `Keeps the item's color and adds underline on the active row`() {
        let sut = makeSUT(colorEnabled: true)
        let item = StyledTestItem(name: "Failed", displayStyle: .failure)

        #expect(sut.title(for: item, isActive: true, maxWidth: 20) == "\u{1B}[1;4;31mFailed\u{1B}[0m")
    }

    @Test
    func `Underlines unstyled active rows without a color`() {
        let sut = makeSUT(colorEnabled: true)

        #expect(sut.title(for: TestItem(name: "Plain"), isActive: true, maxWidth: 20) == "\u{1B}[4mPlain\u{1B}[0m")
    }

    @Test
    func `Uses the theme when a styled item returns no style`() {
        let sut = makeSUT(colorEnabled: true)
        let item = StyledTestItem(name: "Plain", displayStyle: nil)

        #expect(sut.title(for: item, isActive: false, maxWidth: 20) == "\u{1B}[38;5;250mPlain\u{1B}[0m")
    }

    @Test
    func `Truncates the plain name before styling it`() {
        let sut = makeSUT(colorEnabled: true)
        let item = StyledTestItem(name: "VeryLongName", displayStyle: .failure)

        #expect(sut.title(for: item, isActive: false, maxWidth: 5) == "\u{1B}[1;31mVery…\u{1B}[0m")
    }

    @Test
    func `Keeps underline on the active row when color is disabled`() {
        let sut = makeSUT(colorEnabled: false)
        let item = StyledTestItem(name: "Failed", displayStyle: .failure)

        #expect(sut.title(for: item, isActive: true, maxWidth: 20) == "\u{1B}[1;4mFailed\u{1B}[0m")
    }
}

// MARK: - Segments
extension OptionRowFormatterTests {
    @Test
    func `Styles each segment of an inactive row separately`() {
        let sut = makeSUT(colorEnabled: true)
        let item = SegmentedTestItem(segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], displayStyle: nil)

        #expect(sut.title(for: item, isActive: false, maxWidth: 20) == "\u{1B}[38;5;250mjob \u{1B}[0m\u{1B}[1;31mfailed\u{1B}[0m")
    }

    @Test
    func `Uses the item's style for unstyled segments`() {
        let sut = makeSUT(colorEnabled: true)
        let item = SegmentedTestItem(segments: [.init(text: "job ", style: nil), .init(text: "ok", style: .success)], displayStyle: .muted)

        #expect(sut.title(for: item, isActive: false, maxWidth: 20) == "\u{1B}[2mjob \u{1B}[0m\u{1B}[1;32mok\u{1B}[0m")
    }

    @Test
    func `Underlines every segment of the active row`() {
        let sut = makeSUT(colorEnabled: true)
        let item = SegmentedTestItem(segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], displayStyle: nil)

        #expect(sut.title(for: item, isActive: true, maxWidth: 20) == "\u{1B}[4mjob \u{1B}[0m\u{1B}[1;4;31mfailed\u{1B}[0m")
    }

    @Test
    func `Truncates segments before styling them`() {
        let sut = makeSUT(colorEnabled: true)
        let item = SegmentedTestItem(segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], displayStyle: nil)

        #expect(sut.title(for: item, isActive: false, maxWidth: 7) == "\u{1B}[38;5;250mjob \u{1B}[0m\u{1B}[1;31mfa…\u{1B}[0m")
    }

    @Test
    func `Keeps segment attributes but drops colors when color is disabled`() {
        let sut = makeSUT(colorEnabled: false)
        let item = SegmentedTestItem(segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], displayStyle: nil)

        #expect(sut.title(for: item, isActive: false, maxWidth: 20) == "job \u{1B}[1mfailed\u{1B}[0m")
    }
}

// MARK: - SUT
private extension OptionRowFormatterTests {
    func makeSUT(colorEnabled: Bool) -> OptionRowFormatter {
        return OptionRowFormatter(theme: .standard, styler: PickerStyler(colorEnabled: colorEnabled))
    }
}

// MARK: - Test Items
private struct StyledTestItem: StyledPickerItem {
    let name: String
    let displayStyle: PickerTextStyle?

    var displayName: String { name }
}

private struct SegmentedTestItem: SegmentedPickerItem, StyledPickerItem {
    let segments: [PickerTextSegment]
    let displayStyle: PickerTextStyle?

    var displayName: String { segments.map(\.text).joined() }
    var displaySegments: [PickerTextSegment] { segments }
}
