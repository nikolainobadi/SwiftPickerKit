/// How a piece of picker text looks: an optional color plus bold, dim, and underline attributes.
///
/// Add styles of your own in a `PickerTextStyle` extension so call sites read the same as the
/// standard ones:
///
/// ```swift
/// extension PickerTextStyle {
///     static let stale = PickerTextStyle(color: .yellow, isBold: false, isDim: true, isUnderlined: false)
/// }
/// ```
///
/// When the terminal doesn't support color (`NO_COLOR` is set, `TERM` is `dumb`, or output isn't a
/// terminal), the color is dropped and the attributes are kept.
public struct PickerTextStyle: Sendable, Equatable {
    /// The foreground color, or `nil` for the terminal's default foreground color.
    public let color: PickerColor?

    public let isBold: Bool
    public let isDim: Bool
    public let isUnderlined: Bool

    public init(color: PickerColor?, isBold: Bool, isDim: Bool, isUnderlined: Bool) {
        self.color = color
        self.isBold = isBold
        self.isDim = isDim
        self.isUnderlined = isUnderlined
    }
}

// MARK: - Standard Styles
public extension PickerTextStyle {
    static let heading = PickerTextStyle(color: nil, isBold: true, isDim: false, isUnderlined: false)
    static let muted = PickerTextStyle(color: nil, isBold: false, isDim: true, isUnderlined: false)
    static let standout = PickerTextStyle(color: .magenta, isBold: true, isDim: false, isUnderlined: false)
    static let success = PickerTextStyle(color: .green, isBold: true, isDim: false, isUnderlined: false)
    static let warning = PickerTextStyle(color: .yellow, isBold: true, isDim: false, isUnderlined: false)
    static let failure = PickerTextStyle(color: .red, isBold: true, isDim: false, isUnderlined: false)
}

// MARK: - Internal Helpers
extension PickerTextStyle {
    /// A style with only a color, or no attributes at all when `color` is `nil`.
    static func colored(_ color: PickerColor?) -> PickerTextStyle {
        return PickerTextStyle(color: color, isBold: false, isDim: false, isUnderlined: false)
    }

    /// This style with underline turned on.
    var underlined: PickerTextStyle {
        return PickerTextStyle(color: color, isBold: isBold, isDim: isDim, isUnderlined: true)
    }

    /// This style with dim turned on.
    var dimmed: PickerTextStyle {
        return PickerTextStyle(color: color, isBold: isBold, isDim: true, isUnderlined: isUnderlined)
    }
}
