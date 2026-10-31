//
//  PickerFooterRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ANSITerminal

/// Draws the fixed 3-row footer (spacer, divider, instruction text) anchored to the bottom
/// of the screen. Scroll arrows are drawn by `ScrollRenderer`, not here.
struct PickerFooterRenderer {
    private let pickerInput: PickerInput
    private let dividerStyle: PickerDividerStyle

    private let footerHeight: Int = 3

    init(pickerInput: PickerInput, dividerStyle: PickerDividerStyle = .single) {
        self.pickerInput = pickerInput
        self.dividerStyle = dividerStyle
    }
}

// MARK: - Methods for Rendering
extension PickerFooterRenderer {
    /// Rows the footer occupies (always 3); used to size the content area.
    func height() -> Int {
        footerHeight
    }

    /// Clears the bottom rows (`ESC[2K` per line) and redraws the footer there by absolute
    /// positioning, so it stays put while content scrolls. An empty divider still takes its row.
    ///
    /// - Parameter instructionText: Keyboard shortcut text for the last row.
    /// - Returns: Rows consumed (always 3).
    @discardableResult
    func renderFooter(instructionText: String) -> Int {
        let (rows, cols) = pickerInput.readScreenSize()
        let startRow = max(0, rows - footerHeight)

        pickerInput.moveTo(startRow, 0)

        for _ in 0 ..< footerHeight {
            pickerInput.write("\u{1B}[2K")
            pickerInput.write("\n")
        }

        pickerInput.moveTo(startRow, 0)

        var used = 0
        pickerInput.write("\n")
        used += 1

        let divider = dividerStyle.makeLine(width: cols)
        if !divider.isEmpty {
            pickerInput.write(divider + "\n")
        } else {
            pickerInput.write("\n")
        }
        used += 1

        pickerInput.write(instructionText)
        used += 1

        return used
    }
}
