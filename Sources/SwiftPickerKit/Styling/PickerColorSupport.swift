import Foundation

/// Decides whether pickers may emit color escape codes.
enum PickerColorSupport {
    /// Whether standard output, where pickers draw, should receive color.
    static var isEnabledForStandardOutput: Bool {
        return isEnabled(isTerminal: isatty(STDOUT_FILENO) == 1, environment: ProcessInfo.processInfo.environment)
    }

    /// True only when output is a terminal, `NO_COLOR` is unset or empty, and `TERM` isn't `dumb`.
    static func isEnabled(isTerminal: Bool, environment: [String: String]) -> Bool {
        let noColor = environment["NO_COLOR"] ?? ""

        return isTerminal && noColor.isEmpty && environment["TERM"] != "dumb"
    }
}
