//
//  PickerFooterRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Renders the footer section at the bottom of the picker UI with instruction text.
///
/// The footer is anchored to the bottom of the terminal and displays keyboard shortcuts
/// and navigation instructions to guide the user. It remains fixed while the content area
/// scrolls above it.
///
/// ## Layout Structure
///
/// ```
/// ╔═══════════════════════════════════════╗
/// ║                                       ║
/// ║   [Content area scrolls here]         ║
/// ║                                       ║
/// ║───────────────────────────────────────║  ← Footer divider
/// ║ ↑↓: Navigate | Enter: Select | q: Quit   ← Instruction text
/// ╚═══════════════════════════════════════╝
/// ```
///
/// ## Fixed Height
///
/// The footer always consumes exactly **3 rows**:
/// 1. Blank spacer line
/// 2. Horizontal divider line
/// 3. Instruction text line
///
/// This fixed height simplifies scroll calculations in `SelectionHandler`:
/// ```swift
/// contentHeight = screenHeight - headerHeight - 3
/// ```
///
/// ## Positioning
///
/// Unlike the header (which renders from the top), the footer is **anchored to the bottom**.
/// It calculates its starting row as `screenHeight - 3` and renders from there, ensuring it
/// always appears at the bottom regardless of content length.
///
/// ## Scroll Arrows
///
/// **Important:** The footer does NOT render scroll arrows (↑/↓ indicators at the edges
/// of the content area). Those are handled separately by `ScrollRenderer`, which draws them
/// in the content area just above/below the visible items.
///
/// ## Usage
///
/// ```swift
/// let renderer = PickerFooterRenderer(pickerInput: terminal)
///
/// // Get height for scroll calculations
/// let footerHeight = renderer.height()  // Always returns 3
///
/// // Render footer with keyboard instructions
/// renderer.renderFooter(instructionText: "↑↓: Navigate | Enter: Select | q: Quit")
/// ```
///
/// Used by `SelectionHandler` in its render loop to draw the footer after content rendering.
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
    /// Returns the fixed number of rows consumed by the footer.
    ///
    /// This method provides a constant value (3) used by `SelectionHandler` to calculate
    /// available content area height. Having this as a method rather than directly accessing
    /// the private property maintains encapsulation.
    ///
    /// - Returns: Number of rows the footer occupies (always 3)
    func height() -> Int {
        footerHeight
    }

    /// Renders the footer anchored at the bottom of the terminal screen.
    ///
    /// This method performs the footer rendering sequence:
    /// 1. Calculate footer start position: `screenHeight - footerHeight`
    /// 2. Clear the footer area (3 rows) using ANSI escape codes
    /// 3. Move cursor back to footer start position
    /// 4. Write blank spacer line
    /// 5. Write horizontal divider line
    /// 6. Write instruction text
    ///
    /// ## Terminal Positioning
    ///
    /// Uses absolute positioning (`moveTo(row, col)`) to anchor the footer at the bottom,
    /// preventing it from shifting as content scrolls above.
    ///
    /// ## ANSI Escape Codes
    ///
    /// - `\u{1B}[2K` — Clear entire line (used to erase previous footer content)
    ///
    /// ## Structure
    ///
    /// ```
    /// [Blank line]
    /// ─────────────────────────
    /// ↑↓: Navigate | Enter: Select
    /// ```
    ///
    /// - Parameter instructionText: Keyboard shortcut text to display (e.g., "↑↓: Navigate | Enter: Select | q: Quit")
    /// - Returns: Number of rows consumed (always matches `footerHeight`)
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
