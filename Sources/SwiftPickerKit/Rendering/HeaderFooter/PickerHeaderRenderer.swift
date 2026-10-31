//
//  PickerHeaderRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ANSITerminal

/// Draws the header: centered top line, optional prompt, and optional selected-item section
/// with detail lines. Its returned height sizes the content area below it.
struct PickerHeaderRenderer {
    private let pickerInput: PickerInput
    private let dividerStyle: PickerDividerStyle

    init(pickerInput: PickerInput, dividerStyle: PickerDividerStyle = .single) {
        self.pickerInput = pickerInput
        self.dividerStyle = dividerStyle
    }
}

// MARK: - Methods for Rendering
extension PickerHeaderRenderer {
    /// Clears the screen and draws the header from the top.
    ///
    /// Prompt lines (split on `\n`) and detail lines are truncated to `screenWidth - 2` and centered.
    /// The selected-item section is skipped when `selectedItem` is `nil`.
    ///
    /// - Returns: Rows consumed, counting only dividers that produced output.
    @discardableResult
    func renderHeader(prompt: String, topLineText: String, selectedItem: (any DisplayablePickerItem)?, selectedDetailLines: [String] = [], showSelectedItemText: Bool = true, showPromptText: Bool = true, screenWidth: Int) -> Int {
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        var height = 0
        height += writeCentered(topLineText, width: screenWidth)

        if showPromptText {
            height += writeDivider(width: screenWidth)
            let lines = prompt.split(separator: "\n", omittingEmptySubsequences: false)

            for raw in lines {
                let line = String(raw)
                let maxWidth = screenWidth - 2
                let text = line.count > maxWidth ? PickerTextFormatter.truncate(line, maxWidth: maxWidth) : line

                height += writeCentered(text, width: screenWidth)
            }

            height += writeNewline()
        } else {
            height += writeNewline()
        }

        if showSelectedItemText, let item = selectedItem {
            height += writeDivider(width: screenWidth)
            height += writeCentered("Selected: \(item.displayName)".foreColor(51), width: screenWidth)

            for line in selectedDetailLines {
                let maxWidth = screenWidth - 2
                let text = line.count > maxWidth ? PickerTextFormatter.truncate(line, maxWidth: maxWidth) : line
                height += writeCentered(text, width: screenWidth)
            }

            height += writeDivider(width: screenWidth)
            height += writeNewline()
        }

        height += writeNewline()

        return height
    }
}

// MARK: - Private Methods
private extension PickerHeaderRenderer {
    /// Writes nothing and returns 0 when the style produces an empty line.
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
