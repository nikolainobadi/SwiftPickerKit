extension String {
    /// Word-wraps each line to `maxWidth`, keeping existing line breaks and blank lines
    /// (whitespace-only lines become `""`).
    ///
    /// Widths count visible characters, so ANSI escape sequences don't cause early wraps. A style
    /// doesn't carry over a wrap break; style each line separately.
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
            if PickerTextFormatter.visibleWidth(current) + 1 + PickerTextFormatter.visibleWidth(String(word)) <= maxWidth {
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
