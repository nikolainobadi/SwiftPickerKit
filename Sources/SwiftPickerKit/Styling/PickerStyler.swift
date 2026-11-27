/// Applies `PickerTextStyle`s to text with ANSI escape codes.
///
/// When color is disabled, colors are dropped but bold, dim, and underline are kept: `NO_COLOR` only
/// covers color, and underline is what marks the active row in column layouts.
///
/// Styles don't nest. Every styled span ends with a full reset, so truncate plain text first,
/// then style it, and style adjacent pieces separately.
struct PickerStyler: Sendable {
    let colorEnabled: Bool

    init(colorEnabled: Bool) {
        self.colorEnabled = colorEnabled
    }
}

// MARK: - Styling
extension PickerStyler {
    static let reset = "\u{1B}[0m"

    /// Returns `text` in `style`; empty text, or a style with nothing to apply, is returned unchanged.
    func styled(_ text: String, as style: PickerTextStyle) -> String {
        let codes = makeCodes(for: style)

        guard !text.isEmpty, !codes.isEmpty else {
            return text
        }

        return "\u{1B}[" + codes.map { String($0) }.joined(separator: ";") + "m" + text + Self.reset
    }

    /// Returns `text` in `color`, or unchanged when `color` is `nil`.
    func styled(_ text: String, color: PickerColor?) -> String {
        return styled(text, as: .colored(color))
    }
}

// MARK: - Private Methods
private extension PickerStyler {
    func makeCodes(for style: PickerTextStyle) -> [Int] {
        var codes: [Int] = []

        if style.isBold {
            codes.append(1)
        }

        if style.isDim {
            codes.append(2)
        }

        if style.isUnderlined {
            codes.append(4)
        }

        if colorEnabled, let color = style.color {
            codes.append(contentsOf: color.sgrCodes)
        }

        return codes
    }
}
