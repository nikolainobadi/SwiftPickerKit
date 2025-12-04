//
//  PickerHeaderRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Renders the header section of picker UI with title, prompt, and selected item details.
///
/// The header appears at the top of the picker display and contains:
/// - **Top line** — Application name or title (centered)
/// - **Divider** — Visual separator line
/// - **Prompt** — Question or instruction text (multi-line supported, centered)
/// - **Selected item** — Currently focused item with optional detail lines
///
/// ## Layout Structure
///
/// ```
/// ╔═══════════════════════════════════════╗
/// ║         SwiftPicker (centered)        ║
/// ║───────────────────────────────────────║
/// ║   Choose your deployment target:      ║
/// ║                                       ║
/// ║───────────────────────────────────────║
/// ║   Selected: Production (highlighted)  ║
/// ║   Region: us-east-1                   ║
/// ║   Last deploy: 2 hours ago            ║
/// ║───────────────────────────────────────║
/// ║                                       ║
/// ╚═══════════════════════════════════════╝
/// ```
///
/// ## Height Tracking
///
/// The `renderHeader` method returns the number of rows consumed, which `SelectionHandler`
/// uses to calculate available space for the item list (content area).
///
/// ## Text Handling
///
/// - **Prompt text** — Supports multi-line strings with `\n`. Each line is centered and
///   truncated if it exceeds screen width.
/// - **Detail lines** — Optional array of strings shown below the selected item name.
///   Useful for dynamic detail pickers to show item-specific information.
/// - **Selected item** — Highlighted with ANSI color (cyan, code 51).
///
/// ## Visibility Controls
///
/// State objects can control what appears in the header via boolean flags:
/// - `showPromptText` — Hide prompt for cleaner UI (tree navigation does this)
/// - `showSelectedItemText` — Hide selected item display if not needed
///
/// ## Usage
///
/// ```swift
/// let renderer = PickerHeaderRenderer(pickerInput: terminal)
/// let height = renderer.renderHeader(
///     prompt: "Choose deployment target",
///     topLineText: "SwiftPicker",
///     selectedItem: state.options[state.activeIndex].item,
///     selectedDetailLines: ["Region: us-east-1", "Status: Active"],
///     showSelectedItemText: true,
///     showPromptText: true,
///     screenWidth: 80
/// )
/// // height = 9 (used for scroll calculations)
/// ```
///
/// Used by `SelectionHandler` in its render loop to draw the header before content rendering.
import ANSITerminal

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
    /// Renders the complete header section and returns the number of rows consumed.
    ///
    /// This method performs the full header rendering sequence:
    /// 1. Clear screen and move cursor to home position
    /// 2. Write top line text (centered)
    /// 3. Optionally write prompt with dividers (if `showPromptText` is true)
    /// 4. Optionally write selected item with details (if `showSelectedItemText` is true and item exists)
    /// 5. Add spacing before content area
    ///
    /// ## Row Calculation
    ///
    /// The return value is critical for `SelectionHandler` to calculate:
    /// ```swift
    /// contentHeight = screenHeight - headerHeight - footerHeight
    /// visibleRows = contentHeight - scrollArrowRows
    /// ```
    ///
    /// ## Text Processing
    ///
    /// - Prompt lines exceeding `screenWidth - 2` are truncated with ellipsis
    /// - Detail lines exceeding `screenWidth - 2` are truncated with ellipsis
    /// - All text is centered using `PickerTextFormatter.centerText`
    ///
    /// ## Edge Cases
    ///
    /// - `showPromptText = false` — Only top line and selected item shown (tree navigation)
    /// - `selectedItem = nil` — No selected item section rendered
    /// - Empty `selectedDetailLines` — Only item name shown, no additional details
    ///
    /// - Parameters:
    ///   - prompt: Main instruction text (can contain `\n` for multiple lines)
    ///   - topLineText: Title text at top of header (e.g., "SwiftPicker")
    ///   - selectedItem: Currently active/focused item (if any)
    ///   - selectedDetailLines: Additional lines to show below selected item name
    ///   - showSelectedItemText: Whether to display the selected item section
    ///   - showPromptText: Whether to display the prompt section
    ///   - screenWidth: Terminal width in columns
    /// - Returns: Number of rows consumed by the header (used for scroll calculations)
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
    /// Writes a horizontal divider line using the configured style.
    ///
    /// Divider styles are configured at initialization (single, double, or custom).
    /// If the style produces an empty line, no output is written.
    ///
    /// - Parameter width: Terminal width in columns
    /// - Returns: Number of rows consumed (1 if divider written, 0 if empty)
    @discardableResult
    func writeDivider(width: Int) -> Int {
        let line = dividerStyle.makeLine(width: width)
        guard !line.isEmpty else {
            return 0
        }

        pickerInput.write(line + "\n")

        return 1
    }

    /// Writes text centered within the terminal width.
    ///
    /// Uses `PickerTextFormatter.centerText` to calculate left padding,
    /// then writes the padded text followed by a newline.
    ///
    /// - Parameters:
    ///   - text: Text to center and write
    ///   - width: Terminal width in columns
    /// - Returns: Number of rows consumed (always 1)
    @discardableResult
    func writeCentered(_ text: String, width: Int) -> Int {
        pickerInput.write(PickerTextFormatter.centerText(text, inWidth: width))
        pickerInput.write("\n")

        return 1
    }

    /// Writes a blank line for vertical spacing.
    ///
    /// - Returns: Number of rows consumed (always 1)
    @discardableResult
    func writeNewline() -> Int {
        pickerInput.write("\n")

        return 1
    }
}
