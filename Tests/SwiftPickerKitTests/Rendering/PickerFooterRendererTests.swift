//
//  PickerFooterRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct PickerFooterRendererTests {
    @Test
    func `Starting values empty`() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test
    func `Reserves three rows for footer display`() {
        let (sut, _) = makeSUT()

        #expect(sut.height() == 3)
    }

    @Test
    func `Displays divider and instruction text in footer area`() {
        let instructionText = "Use arrows • Enter to confirm"
        let (sut, pickerInput) = makeSUT(screenSize: (rows: 20, cols: 8), dividerStyle: .double)

        let used = sut.renderFooter(instructionText: instructionText)

        #expect(used == 3)
        #expect(pickerInput.moveToCalls.count == 2)
        #expect(pickerInput.moveToCalls.allSatisfy { $0.row == 17 && $0.col == 0 })

        let trailingWrites = Array(pickerInput.writtenText.suffix(3))
        #expect(trailingWrites[0] == "\n")
        #expect(trailingWrites[1] == String(repeating: "=", count: 8) + "\n")
        #expect(trailingWrites[2] == instructionText)
    }

    @Test
    func `Omits divider when style is set to none`() {
        let instructions = "Confirm?"
        let (sut, pickerInput) = makeSUT(screenSize: (rows: 15, cols: 5), dividerStyle: .none)

        _ = sut.renderFooter(instructionText: instructions)

        let clearCommands = pickerInput.writtenText.filter { $0 == "\u{1B}[2K" }
        #expect(clearCommands.count == 3)

        let trailingWrites = Array(pickerInput.writtenText.suffix(2))
        #expect(trailingWrites[0] == "\n")
        #expect(trailingWrites[1] == instructions)
    }
}


// MARK: - SUT
private extension PickerFooterRendererTests {
    func makeSUT(
        screenSize: (rows: Int, cols: Int) = (40, 100),
        dividerStyle: PickerDividerStyle = .single
    ) -> (PickerFooterRenderer, MockPickerInput) {
        let pickerInput = MockPickerInput(screenSize: screenSize)
        let sut = PickerFooterRenderer(pickerInput: pickerInput, dividerStyle: dividerStyle)
        return (sut, pickerInput)
    }
}
