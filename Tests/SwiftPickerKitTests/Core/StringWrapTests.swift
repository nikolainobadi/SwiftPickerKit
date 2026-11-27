import Testing
@testable import SwiftPickerKit

struct StringWrapTests {
    @Test
    func `Wraps plain text at the maximum width`() {
        #expect("alpha beta gamma".wrapToWidth(maxWidth: 10) == ["alpha beta", "gamma"])
    }

    @Test
    func `Does not wrap styled words early because of escape sequences`() {
        let styled = "\u{1B}[31malpha\u{1B}[0m beta"

        #expect(styled.wrapToWidth(maxWidth: 10) == [styled])
    }
}
