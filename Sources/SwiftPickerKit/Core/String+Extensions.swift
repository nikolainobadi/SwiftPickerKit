//
//  String+Extensions.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

extension String {

    /// Wraps a full multiline string into lines that fit a given width,
    /// preserving blank lines and paragraph breaks.
    func wrapToWidth(maxWidth: Int) -> [String] {
        self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .flatMap { line in
                if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    return [""] // preserve blank line
                }
                return line.wrapOneLine(maxWidth: maxWidth)
            }
    }
}

private extension Substring {

    /// Wraps a single line (no newlines) into visual rows.
    func wrapOneLine(maxWidth: Int) -> [String] {
        guard maxWidth > 2 else { return [String(self)] }

        let words = self.split(separator: " ")
        var lines: [String] = []
        var current = ""

        for word in words {
            if current.isEmpty {
                current = String(word)
            } else if current.count + 1 + word.count <= maxWidth {
                current += " \(word)"
            } else {
                lines.append(current)
                current = String(word)
            }
        }

        if !current.isEmpty {
            lines.append(current)
        }

        return lines
    }
}
