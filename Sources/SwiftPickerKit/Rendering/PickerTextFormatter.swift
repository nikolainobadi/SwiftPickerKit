//
//  PickerTextFormatter.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// A utility enum providing static methods for text formatting in picker components.
/// Provides consistent text truncation and centering across all selection handlers.
enum PickerTextFormatter {
    /// Centers text within the specified width.
    /// - Parameters:
    ///   - text: The text to center.
    ///   - width: The width within which to center the text.
    /// - Returns: The centered text with padding.
    static func centerText(_ text: String, inWidth width: Int) -> String {
        let textLength = text.count
        let spaces = (width - textLength) / 2
        let padding = String(repeating: " ", count: max(0, spaces))

        return padding + text
    }

    /// Truncates text to fit within the specified width, adding ellipsis if needed.
    /// - Parameters:
    ///   - text: The text to truncate.
    ///   - maxWidth: The maximum width allowed.
    /// - Returns: The truncated text with ellipsis if it was truncated.
    static func truncate(_ text: String, maxWidth: Int) -> String {
        guard text.count > maxWidth else { return text }
        guard maxWidth > 1 else { return "" }

        let truncatePoint = maxWidth - 1
        let truncated = String(text.prefix(truncatePoint))
        return truncated + "…"
    }
}

