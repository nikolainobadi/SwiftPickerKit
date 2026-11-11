//
//  DefaultTextInputPermissionKeyTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/11/26.
//

import Testing
@testable import SwiftPickerKit

struct DefaultTextInputPermissionKeyTests {
    @Test(arguments: ["y", "Y"])
    func `Answers yes when y is pressed in either case`(key: String) {
        let answer = readPermissionKey(from: key)

        #expect(answer == "y")
    }

    @Test(arguments: ["n", "N"])
    func `Answers no when n is pressed in either case`(key: String) {
        let answer = readPermissionKey(from: key)

        #expect(answer == "n")
    }

    @Test
    func `Ignores other keys until y or n is pressed`() {
        let answer = readPermissionKey(from: "x \r\nq7Y")

        #expect(answer == "y")
    }

    @Test
    func `Stops reading at the first answer key`() {
        var remaining = Array("nyy".utf8)

        _ = DefaultTextInput.readPermissionKey(readByte: { remaining.isEmpty ? nil : remaining.removeFirst() })

        #expect(remaining == Array("yy".utf8))
    }

    @Test
    func `Returns nil when input ends before an answer key`() {
        let answer = readPermissionKey(from: "abc")

        #expect(answer == nil)
    }
}

// MARK: - Helpers
private extension DefaultTextInputPermissionKeyTests {
    func readPermissionKey(from typed: String) -> String? {
        var remaining = Array(typed.utf8)

        return DefaultTextInput.readPermissionKey(readByte: { remaining.isEmpty ? nil : remaining.removeFirst() })
    }
}
