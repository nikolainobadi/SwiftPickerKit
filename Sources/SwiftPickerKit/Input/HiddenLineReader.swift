//
//  HiddenLineReader.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/31/26.
//

/// Reads one line of input with terminal echo turned off, so what the user types never appears.
///
/// The read runs under `SignalHandler`: if Ctrl+C or SIGTERM arrives while echo is off, the
/// cleanup turns echo back on before the signal reaches the host, so an interrupted prompt
/// can't leave the user's shell silently swallowing keystrokes. Afterwards
/// `SignalHandler.wasInterrupted` reports whether this read was the one interrupted.
struct HiddenLineReader {
    private let echo: TerminalEcho
    private let lineSource: () -> String?

    /// - Parameters:
    ///   - echo: Turns echo off for the read and back on afterwards
    ///   - lineSource: Reads the line; returns `nil` at end of input or when interrupted
    init(echo: TerminalEcho, lineSource: @escaping () -> String?) {
        self.echo = echo
        self.lineSource = lineSource
    }
}

// MARK: - Read
extension HiddenLineReader {
    /// Reads one line without echoing it.
    ///
    /// When standard input is not a terminal (piped input, CI), echo can't be turned off and
    /// the line is read as is.
    ///
    /// - Returns: The line, or `nil` at end of input or when the read was interrupted
    func readLine() -> String? {
        // Handlers go in before echo goes off, so there's no window where a signal finds echo
        // disabled with nothing set up to restore it
        SignalHandler.setupSignalHandlers { [echo] in
            echo.restore()
        }
        defer { SignalHandler.removeSignalHandlers() }

        echo.disable()
        defer { echo.restore() }

        return lineSource()
    }
}

// MARK: - Dependencies
/// Turns terminal echo off and back on.
protocol TerminalEcho: AnyObject {
    /// Turns echo off. Does nothing when the input isn't a terminal.
    func disable()

    /// Puts back the settings `disable()` replaced. Does nothing if echo wasn't turned off.
    ///
    /// Called from a signal handler, so it must stay async-signal-safe.
    func restore()
}
