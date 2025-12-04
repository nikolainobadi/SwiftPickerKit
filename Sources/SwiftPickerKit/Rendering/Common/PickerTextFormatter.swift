//
//  PickerTextFormatter.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Utility for text formatting operations used across picker rendering.
///
/// `PickerTextFormatter` provides consistent text manipulation for picker components:
/// - **Centering** — Horizontally center text within terminal width
/// - **Truncation** — Intelligently trim long text with ellipsis
///
/// These operations ensure consistent visual presentation across all picker modes
/// (single-selection, multi-selection, tree navigation, etc.).
///
/// ## Usage
///
/// ```swift
/// // Center a header title
/// let centered = PickerTextFormatter.centerText("SwiftPicker", inWidth: 80)
/// // "                                   SwiftPicker"
///
/// // Truncate long item names
/// let truncated = PickerTextFormatter.truncate("Very long item name that won't fit", maxWidth: 20)
/// // "Very long item name…"
/// ```
///
/// Used internally by:
/// - `PickerHeaderRenderer` — Centers prompt text and titles
/// - `SingleColumnRenderer` — Truncates item names
/// - `TwoColumnDynamicDetailRenderer` — Truncates detail content
enum PickerTextFormatter {
    /// Centers text within the specified width by adding left padding.
    ///
    /// Calculates the required left padding to center the text and prepends spaces.
    /// If text is already wider than the target width, returns it unchanged.
    ///
    /// ## Algorithm
    ///
    /// ```
    /// padding = (width - textLength) / 2
    /// result = (padding spaces) + text
    /// ```
    ///
    /// ## Examples
    ///
    /// ```swift
    /// centerText("Hello", inWidth: 11)  // "   Hello" (3 spaces)
    /// centerText("Hello", inWidth: 3)   // "Hello" (unchanged)
    /// ```
    ///
    /// - Parameters:
    ///   - text: The text to center
    ///   - width: The target width for centering
    /// - Returns: Text with left padding to achieve centering
    static func centerText(_ text: String, inWidth width: Int) -> String {
        let textLength = text.count
        let spaces = (width - textLength) / 2
        let padding = String(repeating: " ", count: max(0, spaces))

        return padding + text
    }

    /// Truncates text to fit within a maximum width, adding ellipsis if truncated.
    ///
    /// If the text is longer than `maxWidth`, it's trimmed to `maxWidth - 1` characters
    /// and a single-character ellipsis (…) is appended. If text already fits, it's
    /// returned unchanged.
    ///
    /// ## Edge Cases
    ///
    /// - `maxWidth <= 1` — Returns empty string (not enough space for meaningful text)
    /// - `text.count <= maxWidth` — Returns text unchanged (no truncation needed)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// truncate("Short", maxWidth: 10)           // "Short"
    /// truncate("Long text here", maxWidth: 10)  // "Long text…"
    /// truncate("Hi", maxWidth: 1)               // ""
    /// ```
    ///
    /// - Parameters:
    ///   - text: The text to potentially truncate
    ///   - maxWidth: Maximum allowed character width
    /// - Returns: Original text or truncated text with ellipsis
    static func truncate(_ text: String, maxWidth: Int) -> String {
        // Text already fits
        guard text.count > maxWidth else {
            return text
        }

        // Not enough space for meaningful text
        guard maxWidth > 1 else {
            return ""
        }

        // Truncate and add ellipsis
        let truncatePoint = maxWidth - 1
        let truncated = String(text.prefix(truncatePoint))

        return truncated + "…"
    }
}
