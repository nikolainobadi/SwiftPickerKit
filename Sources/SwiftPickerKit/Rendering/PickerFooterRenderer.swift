//
//  PickerFooterRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ANSITerminal

struct PickerFooterRenderer {

    private let pickerInput: PickerInput
    private let dividerStyle: PickerDividerStyle

    /// Height of the footer block (number of rows)
    /// You can tune this; it stays consistent.
    private let footerHeight: Int = 3   // arrow / blank / instructions

    init(
        pickerInput: PickerInput,
        dividerStyle: PickerDividerStyle = .single
    ) {
        self.pickerInput = pickerInput
        self.dividerStyle = dividerStyle
    }

    /// Returns the total number of terminal rows the footer occupies.
    func height() -> Int {
        return footerHeight
    }
}
 
// MARK: - Render
extension PickerFooterRenderer {

    /// Renders the footer anchored at the bottom of the terminal window.
    ///
    /// - Parameters:
    ///   - showScrollDownIndicator: Whether to show ↓
    ///   - instructionText: Final instruction line (ex: "Tap 'enter' to select. Type 'q' to quit.")
    @discardableResult
    func renderFooter(
        showScrollDownIndicator: Bool,
        instructionText: String
    ) -> Int {

        let (rows, cols) = pickerInput.readScreenSize()
        let startRow = max(0, rows - footerHeight)

        // ===============================================
        // CLEAR THE FOOTER BLOCK
        // ===============================================
        pickerInput.moveTo(startRow, 0)

        for _ in 0..<footerHeight {
            pickerInput.write("\u{1B}[2K")  // clear whole line
            pickerInput.write("\n")
        }

        // ===============================================
        // RENDER FOOTER CONTENT
        // ===============================================
        pickerInput.moveTo(startRow, 0)

        var used = 0

        // ↓ Scroll-down indicator
        if showScrollDownIndicator {
            pickerInput.write("↓".lightGreen + "\n")
        } else {
            pickerInput.write("\n")
        }
        used += 1

        // Blank spacer line
        pickerInput.write("\n")
        used += 1

        // Divider before instructions (optional — clean look)
        let divider = dividerStyle.makeLine(width: cols)
        if !divider.isEmpty {
            pickerInput.write(divider + "\n")
            used += 1
        }

        // Instructions
        pickerInput.write(instructionText)
        used += 1

        return used
    }
}
