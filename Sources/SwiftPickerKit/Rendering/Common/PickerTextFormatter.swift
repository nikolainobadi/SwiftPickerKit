/// Centering, truncation, and width helpers shared by the renderers.
///
/// Widths count visible `Character`s: ANSI escape sequences (from `ESC` to the first letter) are
/// skipped. Every visible character counts as one column, so wide characters such as emoji can
/// still overflow.
enum PickerTextFormatter {
    /// The number of visible characters in `text`, ignoring escape sequences.
    static func visibleWidth(_ text: String) -> Int {
        guard text.contains(escape) else {
            return text.count
        }

        return split(text).filter { !$0.isEscape }.count
    }

    /// Left-pads `text` to center its visible width in `width`; no right padding is added, and
    /// text wider than `width` is returned unchanged.
    static func centerText(_ text: String, inWidth width: Int) -> String {
        let spaces = (width - visibleWidth(text)) / 2
        let padding = String(repeating: " ", count: max(0, spaces))

        return padding + text
    }

    /// Returns `text` unchanged if its visible width fits; otherwise the first `maxWidth - 1`
    /// visible characters plus "…". Returns `""` when truncation is needed but `maxWidth <= 1`.
    ///
    /// Escape sequences are kept and don't count toward the width. A cut line that contains any
    /// escape sequence ends with a style reset, so a cut-off style can't leak past it.
    static func truncate(_ text: String, maxWidth: Int) -> String {
        guard text.contains(escape) else {
            return truncatePlain(text, maxWidth: maxWidth)
        }

        let pieces = split(text)
        let visibleCount = pieces.filter { !$0.isEscape }.count

        guard visibleCount > maxWidth else {
            return text
        }

        guard maxWidth > 1 else {
            return ""
        }

        return cut(pieces, keepingVisibleCount: maxWidth - 1) + ellipsis + PickerStyler.reset
    }

    /// Returns `segments` unchanged if their combined width fits; otherwise the segments covering
    /// the first `maxWidth - 1` characters, with "…" appended to the segment that was cut so it
    /// keeps that segment's style. Returns `[]` when truncation is needed but `maxWidth <= 1`.
    ///
    /// Segment text is treated as plain: each `Character` counts as one column.
    static func truncate(_ segments: [PickerTextSegment], maxWidth: Int) -> [PickerTextSegment] {
        let totalWidth = segments.reduce(0) { $0 + $1.text.count }

        guard totalWidth > maxWidth else {
            return segments
        }

        guard maxWidth > 1 else {
            return []
        }

        var remaining = maxWidth - 1
        var result: [PickerTextSegment] = []

        for segment in segments {
            guard segment.text.count <= remaining else {
                result.append(.init(text: String(segment.text.prefix(remaining)) + ellipsis, style: segment.style))
                break
            }

            result.append(segment)
            remaining -= segment.text.count
        }

        return result
    }
}

// MARK: - Private Methods
private extension PickerTextFormatter {
    static let escape: Character = "\u{1B}"
    static let ellipsis = "…"

    static func truncatePlain(_ text: String, maxWidth: Int) -> String {
        guard text.count > maxWidth else {
            return text
        }

        guard maxWidth > 1 else {
            return ""
        }

        return String(text.prefix(maxWidth - 1)) + ellipsis
    }

    static func split(_ text: String) -> [TextPiece] {
        var pieces: [TextPiece] = []
        var escapeSequence = ""

        for character in text {
            if character == escape {
                escapeSequence = String(character)
            } else if escapeSequence.isEmpty {
                pieces.append(.init(text: String(character), isEscape: false))
            } else {
                escapeSequence.append(character)

                if character.isLetter {
                    pieces.append(.init(text: escapeSequence, isEscape: true))
                    escapeSequence = ""
                }
            }
        }

        if !escapeSequence.isEmpty {
            pieces.append(.init(text: escapeSequence, isEscape: true))
        }

        return pieces
    }

    static func cut(_ pieces: [TextPiece], keepingVisibleCount keptCount: Int) -> String {
        var result = ""
        var visibleCount = 0

        for piece in pieces {
            if piece.isEscape {
                result += piece.text
            } else if visibleCount < keptCount {
                result += piece.text
                visibleCount += 1
            }
        }

        return result
    }
}

// MARK: - Dependencies
private struct TextPiece {
    let text: String
    let isEscape: Bool
}
