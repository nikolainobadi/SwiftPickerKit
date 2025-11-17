//
//  PickerHeaderRenderer.swift
//  SwiftPickerKit
//

import ANSITerminal

struct PickerHeaderRenderer {
    private let pickerInput: PickerInput
    
    init(pickerInput: PickerInput) {
        self.pickerInput = pickerInput
    }
}

// MARK: - Render
extension PickerHeaderRenderer {
    func renderHeader(
        prompt: String,
        topLineText: String,
        selectedItem: (any DisplayablePickerItem)?,
        screenWidth: Int,
        showScrollUpIndicator: Bool
    ) {
        pickerInput.clearScreen()
        pickerInput.moveToHome()
        
        // TOP-LINE TEXT
        pickerInput.write(center(topLineText, width: screenWidth) + "\n")
        renderDivider(width: screenWidth)
        
        // PROMPT (supports multi-line)
        let lines = prompt
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
        
        for line in lines {
            let max = screenWidth - 2
            let truncated = line.count > max
                ? PickerTextFormatter.truncate(line, maxWidth: max)
                : line
            pickerInput.write(center(truncated, width: screenWidth) + "\n")
        }
        
        renderDivider(width: screenWidth)
        
        // SELECTED ITEM
        if let item = selectedItem {
            renderDivider(width: screenWidth)
            renderSelectedItem(item, width: screenWidth)
            renderDivider(width: screenWidth)
            pickerInput.write("\n")
        }
        
        // SCROLL UP ARROW
        if showScrollUpIndicator {
            pickerInput.write("↑".lightGreen + "\n")
        }
        
        // Gap before list
        pickerInput.write("\n")
    }
}

// MARK: - Helpers
private extension PickerHeaderRenderer {
    func renderDivider(width: Int) {
        pickerInput.write(String(repeating: "─", count: width) + "\n")
    }
    
    func center(_ text: String, width: Int) -> String {
        PickerTextFormatter.centerText(text, inWidth: width)
    }
    
    func renderSelectedItem(_ item: any DisplayablePickerItem, width: Int) {
        let text = "Selected: \(item.displayName)"
        let maxWidth = width - 2
        let use = text.count > maxWidth ? PickerTextFormatter.truncate(text, maxWidth: maxWidth) : text
        
        let centered = PickerTextFormatter.centerText(use, inWidth: width)
        pickerInput.write(centered.foreColor(51) + "\n")
    }
}
