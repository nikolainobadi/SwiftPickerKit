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
    /// Always consistent. Scroll arrows are now handled elsewhere.
    private let footerHeight: Int = 3 // spacer / divider / instructions

    init(pickerInput: PickerInput, dividerStyle: PickerDividerStyle = .single) {
        self.pickerInput = pickerInput
        self.dividerStyle = dividerStyle
    }
}

// MARK: - Render

extension PickerFooterRenderer {
    /// Returns number of rows consumed by footer.
    func height() -> Int {
        footerHeight
    }

    /// Renders footer anchored at bottom of terminal.
    ///
    /// Structure:
    ///     1. Blank spacer line
    ///     2. Divider line
    ///     3. Instruction text
    ///
    /// Scroll arrows are rendered by ScrollRenderer, not here.
    @discardableResult
    func renderFooter(instructionText: String) -> Int {
        let (rows, cols) = pickerInput.readScreenSize()
        let startRow = max(0, rows - footerHeight)

        // ===============================================
        // CLEAR FOOTER BLOCK
        // ===============================================
        pickerInput.moveTo(startRow, 0)

        for _ in 0 ..< footerHeight {
            pickerInput.write("\u{1B}[2K") // clear line
            pickerInput.write("\n")
        }

        // ===============================================
        // RENDER FOOTER CONTENT
        // ===============================================
        pickerInput.moveTo(startRow, 0)

        var used = 0

        // 1. Blank spacer line
        pickerInput.write("\n")
        used += 1

        // 2. Divider
        let divider = dividerStyle.makeLine(width: cols)
        if !divider.isEmpty {
            pickerInput.write(divider + "\n")
        } else {
            pickerInput.write("\n")
        }
        used += 1

        // 3. Instructions
        pickerInput.write(instructionText)
        used += 1

        return used
    }
}
