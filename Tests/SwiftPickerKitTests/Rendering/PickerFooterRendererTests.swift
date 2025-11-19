//
//  PickerFooterRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct PickerFooterRendererTests {
    @Test("height always returns footer block size")
    func heightAlwaysReturnsFooterBlockSize() {
        let sut = PickerFooterRenderer(pickerInput: MockPickerInput())

        #expect(sut.height() == 3)
    }

    @Test("renderFooter clears block and writes spacer divider and instructions")
    func renderFooterClearsAndWritesFooterContent() {
        let instructionText = "Use arrows • Enter to confirm"
        let pickerInput = MockPickerInput(screenSize: (rows: 20, cols: 8))
        let sut = PickerFooterRenderer(pickerInput: pickerInput, dividerStyle: .double)

        let used = sut.renderFooter(instructionText: instructionText)

        #expect(used == 3)
        #expect(pickerInput.moveToCalls.count == 2)
        #expect(pickerInput.moveToCalls.allSatisfy { $0.row == 17 && $0.col == 0 })

        let trailingWrites = Array(pickerInput.writtenText.suffix(3))
        #expect(trailingWrites[0] == "\n")
        #expect(trailingWrites[1] == String(repeating: "=", count: 8) + "\n")
        #expect(trailingWrites[2] == instructionText)
    }

    @Test("renderFooter falls back to newline when divider style is none")
    func renderFooterFallsBackToNewlineWhenDividerStyleIsNone() {
        let pickerInput = MockPickerInput(screenSize: (rows: 15, cols: 5))
        let sut = PickerFooterRenderer(pickerInput: pickerInput, dividerStyle: .none)
        let instructions = "Confirm?"

        _ = sut.renderFooter(instructionText: instructions)

        let clearCommands = pickerInput.writtenText.filter { $0 == "\u{1B}[2K" }
        #expect(clearCommands.count == 3)

        let trailingWrites = Array(pickerInput.writtenText.suffix(2))
        #expect(trailingWrites[0] == "\n")
        #expect(trailingWrites[1] == instructions)
    }
}
