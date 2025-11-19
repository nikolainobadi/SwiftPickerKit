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
    /// Height of the footer block (number of rows). Scroll arrows are handled elsewhere.
    private let footerHeight: Int = 3

    init(pickerInput: PickerInput, dividerStyle: PickerDividerStyle = .single) {
        self.pickerInput = pickerInput
        self.dividerStyle = dividerStyle
    }
}


// MARK: - Methods for Rendering
extension PickerFooterRenderer {
    /// Returns number of rows consumed by footer.
    func height() -> Int {
        footerHeight
    }

    /// Renders footer anchored at bottom of terminal.
    /// Structure: spacer line, divider line, instruction text.
    /// Scroll arrows are rendered by ScrollRenderer.
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
