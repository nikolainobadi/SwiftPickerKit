//
//  PickerHeaderRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ANSITerminal

/// A reusable component for rendering picker headers consistently across different selection modes.
/// Handles rendering of top line text, title, selected item display, and scroll indicators.
struct PickerHeaderRenderer {
    /// The input handler for writing to the terminal.
    private let pickerInput: PickerInput
    
    init(pickerInput: PickerInput) {
        self.pickerInput = pickerInput
    }
}


// MARK: - Actions
extension PickerHeaderRenderer {
    /// Renders the complete header section for a picker.
    /// - Parameters:
    ///   - topLineText: The text to display at the top of the header (centered).
    ///   - title: The main title text to display.
    ///   - selectedItem: The currently selected item to display (if any).
    ///   - screenWidth: The width of the screen for centering and truncation.
    ///   - showScrollUpIndicator: Whether to show the scroll up indicator (↑).
    func renderHeader(
        topLineText: String,
        title: String,
        selectedItem: (any DisplayablePickerItem)?,
        screenWidth: Int,
        showScrollUpIndicator: Bool
    ) {
        pickerInput.clearScreen()
        pickerInput.moveToHome()
        pickerInput.write(centerText(topLineText, inWidth: screenWidth))
        pickerInput.write("\n")
        pickerInput.write("\n")

        // Render selected item between topLineText and title
        if let selectedItem = selectedItem {
            renderSelectedItem(selectedItem, screenWidth: screenWidth)
            pickerInput.write("\n")
        }

        // Truncate and center title if needed
        let maxTitleWidth = screenWidth - 2
        let truncatedTitle = title.count > maxTitleWidth
            ? PickerTextFormatter.truncate(title, maxWidth: maxTitleWidth)
            : title
        pickerInput.write(centerText(truncatedTitle, inWidth: screenWidth))
        pickerInput.write("\n")
        if showScrollUpIndicator {
            pickerInput.write("↑".lightGreen)
        }
    }
}


// MARK: - Private Methods
private extension PickerHeaderRenderer {
    /// Renders the currently selected item inline during header rendering.
    /// Uses PickerTextFormatter for consistent text formatting.
    /// - Parameters:
    ///   - item: The item to display.
    ///   - screenWidth: The width of the screen for centering.
    func renderSelectedItem(_ item: any DisplayablePickerItem, screenWidth: Int) {
        let itemName = item.displayName
        let textWithLabel = "Selected: \(itemName)"

        // Truncate if too long for screen width
        let maxWidth = screenWidth - 2
        let finalText = textWithLabel.count > maxWidth
            ? PickerTextFormatter.truncate(textWithLabel, maxWidth: maxWidth)
            : textWithLabel

        // Center and display in cyan color
        let centeredText = PickerTextFormatter.centerText(finalText, inWidth: screenWidth)
        pickerInput.write(centeredText.foreColor(51))  // Cyan color
    }

    /// Centers the given text within the specified width.
    /// - Parameters:
    ///   - text: The text to center.
    ///   - width: The width within which to center the text.
    /// - Returns: The centered text.
    func centerText(_ text: String, inWidth width: Int) -> String {
        PickerTextFormatter.centerText(text, inWidth: width)
    }
}
