//
//  String+Extensions.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

/// Internal text formatting utilities for SwiftPickerKit.
///
/// These extensions provide text wrapping functionality used by the picker's rendering system
/// to ensure text fits within terminal width constraints while preserving paragraph structure.
extension String {
    /// Wraps a multiline string into lines that fit within a specified width.
    ///
    /// This method:
    /// - Preserves blank lines (paragraph breaks)
    /// - Wraps long lines at word boundaries
    /// - Maintains original line breaks where they fit
    ///
    /// Used internally by `PickerHeaderRenderer` and `PickerTextFormatter` to wrap
    /// prompt text and detail content to fit the terminal width.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let text = """
    /// This is a very long line that needs to be wrapped to fit within the terminal width.
    ///
    /// This is a new paragraph.
    /// """
    /// let wrapped = text.wrapToWidth(maxWidth: 40)
    /// // Returns: [
    /// //   "This is a very long line that needs",
    /// //   "to be wrapped to fit within the",
    /// //   "terminal width.",
    /// //   "",
    /// //   "This is a new paragraph."
    /// // ]
    /// ```
    ///
    /// - Parameter maxWidth: Maximum character width for wrapped lines
    /// - Returns: Array of wrapped lines, preserving blank lines for paragraph breaks
    func wrapToWidth(maxWidth: Int) -> [String] {
        split(separator: "\n", omittingEmptySubsequences: false)
            .flatMap { line in
                // Preserve blank lines (paragraph breaks)
                guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return [""]
                }

                // Wrap the line at word boundaries
                return line.wrapOneLine(maxWidth: maxWidth)
            }
    }
}


// MARK: - Private Helpers
private extension Substring {
    /// Wraps a single line (without newlines) into multiple lines at word boundaries.
    ///
    /// Uses a greedy word-wrapping algorithm that tries to fit as many complete words
    /// on each line as possible without exceeding `maxWidth`.
    ///
    /// - Parameter maxWidth: Maximum character width per line
    /// - Returns: Array of wrapped lines
    func wrapOneLine(maxWidth: Int) -> [String] {
        // Edge case: if maxWidth is too small, just return the line as-is
        guard maxWidth > 2 else { return [String(self)] }

        let words = split(separator: " ")
        var lines: [String] = []
        var current = ""

        for word in words {
            // First word on the line
            if current.isEmpty {
                current = String(word)
                continue
            }

            // Try adding the word to the current line (accounting for space character)
            if current.count + 1 + word.count <= maxWidth {
                current += " \(word)"
                continue
            }

            // Word doesn't fit — finalize current line and start a new one
            lines.append(current)
            current = String(word)
        }

        // Don't forget the last line
        if !current.isEmpty {
            lines.append(current)
        }

        return lines
    }
}
