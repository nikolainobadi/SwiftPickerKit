//
//  StandardInputEcho.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/31/26.
//

import Foundation

/// Controls echo on standard input's terminal through `termios`.
///
/// `getpass(3)` would do the same in one call, but it's marked obsolete and caps input at
/// 128 characters on macOS.
final class StandardInputEcho: TerminalEcho {
    private var savedSettings = termios()
    private var isDisabled = false

    func disable() {
        guard isatty(STDIN_FILENO) == 1, tcgetattr(STDIN_FILENO, &savedSettings) == 0 else {
            return
        }

        var hiddenSettings = savedSettings
        hiddenSettings.c_lflag &= ~tcflag_t(ECHO)

        // TCSAFLUSH drops anything typed ahead before the prompt, as password prompts do
        if tcsetattr(STDIN_FILENO, TCSAFLUSH, &hiddenSettings) == 0 {
            isDisabled = true
        }
    }

    func restore() {
        guard isDisabled else {
            return
        }

        // tcsetattr is async-signal-safe, so this is safe from the signal handler
        tcsetattr(STDIN_FILENO, TCSANOW, &savedSettings)
        isDisabled = false
    }
}
