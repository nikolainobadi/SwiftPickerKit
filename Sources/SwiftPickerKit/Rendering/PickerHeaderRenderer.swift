//
//  PickerHeaderRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ANSITerminal

struct PickerHeaderRenderer {
    private let pickerInput: PickerInput
    private let dividerStyle: PickerDividerStyle

    init(pickerInput: PickerInput, dividerStyle: PickerDividerStyle = .single) {
        self.pickerInput = pickerInput
        self.dividerStyle = dividerStyle
    }
}

// MARK: - Render
extension PickerHeaderRenderer {
    @discardableResult
    func renderHeader(
        prompt: String,
        topLineText: String,
        selectedItem: (any DisplayablePickerItem)?,
        screenWidth: Int
    ) -> Int {

        pickerInput.clearScreen()
        pickerInput.moveToHome()

        var height = 0

        // =========================================================
        // TOP-LINE (e.g. "InteractivePicker (single-selection)")
        // =========================================================
        height += writeCentered(topLineText, width: screenWidth)

        // =========================================================
        // DIVIDER
        // =========================================================
        height += writeDivider(width: screenWidth)

        // =========================================================
        // MULTI-LINE PROMPT
        // =========================================================
        let lines = prompt.split(separator: "\n", omittingEmptySubsequences: false)

        for raw in lines {
            let line = String(raw)
            let maxWidth = screenWidth - 2
            let text = line.count > maxWidth
                ? PickerTextFormatter.truncate(line, maxWidth: maxWidth)
                : line

            height += writeCentered(text, width: screenWidth)
        }

        // Small breathing room after prompt
        height += writeNewline()

        // =========================================================
        // SELECTED ITEM (optional)
        // =========================================================
        if let item = selectedItem {
            height += writeDivider(width: screenWidth)
            height += writeCentered("Selected: \(item.displayName)".foreColor(51), width: screenWidth)
            height += writeDivider(width: screenWidth)
            height += writeNewline()
        }

        // =========================================================
        // SPACER BEFORE LIST
        // (arrow rendering is now handled by ScrollRenderer)
        // =========================================================
        height += writeNewline()

        return height
    }
}

// MARK: - Private Helpers
private extension PickerHeaderRenderer {
    @discardableResult
    func writeDivider(width: Int) -> Int {
        let line = dividerStyle.makeLine(width: width)
        
        guard !line.isEmpty else {
            return 0
        }
        
        pickerInput.write(line + "\n")
        
        return 1
    }

    @discardableResult
    func writeCentered(_ text: String, width: Int) -> Int {
        pickerInput.write(PickerTextFormatter.centerText(text, inWidth: width))
        pickerInput.write("\n")
        
        return 1
    }

    @discardableResult
    func writeNewline() -> Int {
        pickerInput.write("\n")
        
        return 1
    }
}
