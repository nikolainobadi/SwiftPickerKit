import Testing
@testable import SwiftPickerKit

struct PickerColorSupportTests {
    @Test
    func `Enables color for a terminal with no overrides`() {
        #expect(PickerColorSupport.isEnabled(isTerminal: true, environment: ["TERM": "xterm-256color"]))
    }

    @Test
    func `Disables color when output is not a terminal`() {
        #expect(PickerColorSupport.isEnabled(isTerminal: false, environment: ["TERM": "xterm-256color"]) == false)
    }

    @Test
    func `Disables color when NO_COLOR is set`() {
        #expect(PickerColorSupport.isEnabled(isTerminal: true, environment: ["NO_COLOR": "1"]) == false)
    }

    @Test
    func `Ignores an empty NO_COLOR value`() {
        #expect(PickerColorSupport.isEnabled(isTerminal: true, environment: ["NO_COLOR": ""]))
    }

    @Test
    func `Disables color for a dumb terminal`() {
        #expect(PickerColorSupport.isEnabled(isTerminal: true, environment: ["TERM": "dumb"]) == false)
    }
}
