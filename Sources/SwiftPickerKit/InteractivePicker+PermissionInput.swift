//
//  InteractivePicker+PermissionInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public extension InteractivePicker {
    /// Prompts the user for permission with a yes/no question.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: `true` if the user grants permission, `false` otherwise.
    func getPermission(prompt: PickerPrompt) -> Bool {
        return textInput.getPermission(prompt.title)
    }

    /// Prompts the user for permission with a yes/no question and requires a yes to proceed.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Throws: `SwiftPickerError.selectionCancelled` if the user does not grant permission.
    func requiredPermission(prompt: PickerPrompt) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}
