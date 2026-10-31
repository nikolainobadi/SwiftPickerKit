//
//  String+Extensions.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

extension String {
    /// Word-wraps each line to `maxWidth`, keeping existing line breaks and blank lines
    /// (whitespace-only lines become `""`).
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

// MARK: - Private Helpers
private extension Substring {
    /// Greedily wraps a single line at spaces. A word longer than `maxWidth` is not split,
    /// and `maxWidth <= 2` returns the line unwrapped.
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

            // +1 for the joining space
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
