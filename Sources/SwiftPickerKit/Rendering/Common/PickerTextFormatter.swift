//
//  PickerTextFormatter.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Centering and truncation helpers shared by the renderers. Widths are measured in
/// `Character` count, so ANSI escape codes in the input are counted as visible width.
enum PickerTextFormatter {
    /// Left-pads `text` to center it in `width`; no right padding is added, and text wider
    /// than `width` is returned unchanged.
    static func centerText(_ text: String, inWidth width: Int) -> String {
        let textLength = text.count
        let spaces = (width - textLength) / 2
        let padding = String(repeating: " ", count: max(0, spaces))

        return padding + text
    }

    /// Returns `text` unchanged if it fits; otherwise the first `maxWidth - 1` characters plus "…".
    /// Returns `""` when truncation is needed but `maxWidth <= 1`.
    static func truncate(_ text: String, maxWidth: Int) -> String {
        guard text.count > maxWidth else {
            return text
        }

        guard maxWidth > 1 else {
            return ""
        }

        let truncatePoint = maxWidth - 1
        let truncated = String(text.prefix(truncatePoint))

        return truncated + "…"
    }
}
