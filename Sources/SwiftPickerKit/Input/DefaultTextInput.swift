//
//  DefaultTextInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation

struct DefaultTextInput: TextInput {
    let permissionSubmitMode: PermissionSubmitMode

    func getInput(_ prompt: String) -> String {
        return getInput(prompt, retryCount: 0)
    }

    func getSecretInput(_ prompt: String) -> String {
        return getSecretInput(prompt, retryCount: 0)
    }

    func getPermission(_ prompt: String) -> Bool {
        return getPermission(prompt, retryCount: 0)
    }
}

// MARK: - Private Methods
private extension DefaultTextInput {
    func getInput(_ prompt: String, retryCount: Int) -> String {
        return readWithRetry(prompt, retryCount: retryCount, readLine: { readLine() }, wasInterrupted: { false })
    }

    func getSecretInput(_ prompt: String, retryCount: Int) -> String {
        return readWithRetry(prompt, retryCount: retryCount, readLine: {
            let secret = makeHiddenLineReader().readLine()

            // The Enter that ended the line wasn't echoed either
            print("")
            return secret
        }, wasInterrupted: { SignalHandler.wasInterrupted })
    }

    /// Prompts and reads a line, offering up to two retries when nothing was typed.
    ///
    /// - Parameters:
    ///   - readLine: Reads the answer; `nil` at end of input or when interrupted
    ///   - wasInterrupted: Whether the read just made was ended by a signal, in which case the
    ///     host keeps running and the prompt finishes rather than asking to retry
    func readWithRetry(_ prompt: String, retryCount: Int, readLine: () -> String?, wasInterrupted: () -> Bool) -> String {
        print("\(prompt)\n")
        if let answer = readLine(), !answer.isEmpty {
            return answer
        }

        guard !wasInterrupted(), retryCount < 2 else {
            return ""
        }

        guard getPermission("\nYou didn't type anything. Would you like to try again?") else {
            return ""
        }

        return readWithRetry(prompt, retryCount: retryCount + 1, readLine: readLine, wasInterrupted: wasInterrupted)
    }

    func makeHiddenLineReader() -> HiddenLineReader {
        return HiddenLineReader(echo: StandardInputEcho(disablesLineBuffering: false), lineSource: {
            let line = readLine()

            // An interrupted read leaves stdin's error flag set; clear it so later reads work
            if line == nil {
                clearerr(stdin)
            }

            return line
        })
    }

    func getPermission(_ prompt: String, retryCount: Int) -> Bool {
        print("\n\(prompt)", terminator: " (\("y".green)/\("n".red)) ")

        // A pipe has no keypresses to take, so non-terminal input always reads a line
        if permissionSubmitMode == .immediate, isatty(STDIN_FILENO) == 1 {
            return getImmediatePermission()
        }

        guard let answer = readLine(), !answer.isEmpty else {
            if retryCount > 1 {
                print("Fine, I'll take that as a no!".red)
                return false
            } else {
                print("type 'y' or 'n'\n".yellow)
                return getPermission(prompt, retryCount: retryCount + 1)
            }
        }

        return answer == "y" || answer == "Y"
    }

    /// Takes the answer from the first `y` or `n` keypress, without waiting for Enter.
    ///
    /// The read runs through `HiddenLineReader`, so its signal cleanup restores line buffering
    /// and echo before an interrupt reaches the host. The prompt prints the answer itself,
    /// because the terminal doesn't echo it.
    func getImmediatePermission() -> Bool {
        // The prompt ends without a newline, so it may still be sitting in the buffer
        fflush(stdout)

        let reader = HiddenLineReader(echo: StandardInputEcho(disablesLineBuffering: true), lineSource: {
            return DefaultTextInput.readPermissionKey(readByte: {
                var byte: UInt8 = 0

                // 0 at end of input, -1 when an interrupt the host handles ends the read
                return read(STDIN_FILENO, &byte, 1) == 1 ? byte : nil
            })
        })
        let answer = reader.readLine()

        print(answer ?? "")
        return answer == "y"
    }
}

// MARK: - Key Reading
extension DefaultTextInput {
    /// Reads bytes until one answers a permission prompt.
    ///
    /// - Parameter readByte: Reads the next byte; `nil` at end of input or when interrupted
    /// - Returns: `"y"` for `y`/`Y`, `"n"` for `n`/`N`, or `nil` if input ended before either
    static func readPermissionKey(readByte: () -> UInt8?) -> String? {
        while let byte = readByte() {
            switch byte {
            case UInt8(ascii: "y"), UInt8(ascii: "Y"):
                return "y"
            case UInt8(ascii: "n"), UInt8(ascii: "N"):
                return "n"
            default:
                continue
            }
        }

        return nil
    }
}
