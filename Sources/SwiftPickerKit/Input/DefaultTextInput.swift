//
//  DefaultTextInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation

struct DefaultTextInput: TextInput {
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
        return HiddenLineReader(echo: StandardInputEcho(), lineSource: {
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
}
