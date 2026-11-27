import Testing
@testable import SwiftPickerKit

struct PickerColorTests {
    @Test
    func `Named colors map to standard foreground codes`() {
        #expect(PickerColor.black.sgrCodes == [30])
        #expect(PickerColor.red.sgrCodes == [31])
        #expect(PickerColor.white.sgrCodes == [37])
    }

    @Test
    func `Bright colors map to high intensity foreground codes`() {
        #expect(PickerColor.brightBlack.sgrCodes == [90])
        #expect(PickerColor.brightGreen.sgrCodes == [92])
        #expect(PickerColor.brightWhite.sgrCodes == [97])
    }

    @Test
    func `Palette colors map to 256-color foreground codes`() {
        #expect(PickerColor.palette(250).sgrCodes == [38, 5, 250])
        #expect(PickerColor.palette(0).sgrCodes == [38, 5, 0])
    }
}
