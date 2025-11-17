//
//  InteractivePicker+TextInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public extension InteractivePicker {
    /// Prompts the user for input with the given prompt string.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: The user's input as a String.
    func getInput(prompt: String) -> String {
        return textInput.getInput(prompt)
    }

    /// Prompts the user for input with the given prompt string and requires input.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Throws: `SwiftPickerError.inputRequired` if the user does not provide any input.
    /// - Returns: The user's input as a String.
    func getRequiredInput(prompt: String) throws -> String {
        let input = getInput(prompt: prompt)
        if input.isEmpty {
            throw SwiftPickerError.inputRequired
        }
        return input
    }
}
