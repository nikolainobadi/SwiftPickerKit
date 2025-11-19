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
        split(separator: "\n", omittingEmptySubsequences: false)
            .flatMap { line in
                guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return [""]
                }

                return line.wrapOneLine(maxWidth: maxWidth)
            }
    }
}


// MARK: - Substring Helpers
private extension Substring {
    /// Wraps a single line (no newlines) into visual rows.
    func wrapOneLine(maxWidth: Int) -> [String] {
        guard maxWidth > 2 else { return [String(self)] }

        let words = split(separator: " ")
        var lines: [String] = []
        var current = ""

        for word in words {
            if current.isEmpty {
                current = String(word)
                continue
            }

            if current.count + 1 + word.count <= maxWidth {
                current += " \(word)"
                continue
            }

            lines.append(current)
            current = String(word)
        }

        if !current.isEmpty {
            lines.append(current)
        }

        return lines
    }
}
