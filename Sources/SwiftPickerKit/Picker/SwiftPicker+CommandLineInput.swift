//
//  SwiftPicker+CommandLineInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

extension SwiftPicker: CommandLineInput {
    /// Prompts the user for input with the given prompt string.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: The user's input as a String.
    public func getInput(prompt: String) -> String {
        return textInput.getInput(prompt)
    }

    /// Prompts the user for input without echoing what they type.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: The user's input as a String, or an empty string if the prompt was interrupted.
    public func getSecretInput(prompt: String) -> String {
        let input = textInput.getSecretInput(prompt)

        if SignalHandler.wasInterrupted {
            waitForTermination?()
        }

        return input
    }
}
