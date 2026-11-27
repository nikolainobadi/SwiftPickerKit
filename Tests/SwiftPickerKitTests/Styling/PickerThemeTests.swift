import Testing
@testable import SwiftPickerKit

struct PickerThemeTests {
    @Test
    func `Standard theme keeps the previous marker and arrow colors`() {
        let sut = PickerTheme.standard

        #expect(sut.marker == .brightGreen)
        #expect(sut.activePointer == .brightGreen)
        #expect(sut.scrollArrow == .brightGreen)
        #expect(sut.breadcrumb == .brightBlue)
    }

    @Test
    func `Standard theme keeps the previous palette grays`() {
        let sut = PickerTheme.standard

        #expect(sut.inactiveText == .palette(250))
        #expect(sut.detailText == .palette(250))
        #expect(sut.divider == .palette(240))
        #expect(sut.inactivePointer == .palette(244))
        #expect(sut.placeholder == .palette(240))
        #expect(sut.subtitle == .palette(240))
        #expect(sut.metadataDetail == .palette(244))
    }

    @Test
    func `Standard theme keeps the previous accent colors`() {
        let sut = PickerTheme.standard

        #expect(sut.emptyHint == .palette(208))
        #expect(sut.columnHeader == .palette(102))
        #expect(sut.selectedHeader == .palette(51))
    }
}
