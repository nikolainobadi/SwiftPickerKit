/// A terminal foreground color: one of the 16 named ANSI colors, or an entry in the 256-color palette.
///
/// The exact shade of each named color comes from the user's terminal palette. Use `.palette(_:)`
/// for xterm 256-color values such as the grays the standard theme uses.
public enum PickerColor: Sendable, Equatable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    case brightBlack
    case brightRed
    case brightGreen
    case brightYellow
    case brightBlue
    case brightMagenta
    case brightCyan
    case brightWhite

    /// An xterm 256-color palette index (0–255).
    case palette(UInt8)
}

// MARK: - Escape Codes
extension PickerColor {
    /// The SGR parameters that select this color as the foreground.
    var sgrCodes: [Int] {
        switch self {
        case .black:
            return [30]
        case .red:
            return [31]
        case .green:
            return [32]
        case .yellow:
            return [33]
        case .blue:
            return [34]
        case .magenta:
            return [35]
        case .cyan:
            return [36]
        case .white:
            return [37]
        case .brightBlack:
            return [90]
        case .brightRed:
            return [91]
        case .brightGreen:
            return [92]
        case .brightYellow:
            return [93]
        case .brightBlue:
            return [94]
        case .brightMagenta:
            return [95]
        case .brightCyan:
            return [96]
        case .brightWhite:
            return [97]
        case .palette(let index):
            return [38, 5, Int(index)]
        }
    }
}
