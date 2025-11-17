//
//  SwiftPicker+PermissionInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public extension SwiftPicker {
    /// Prompts the user for permission with a yes/no question.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: `true` if the user grants permission, `false` otherwise.
    func getPermission(prompt: String) -> Bool {
        return textInput.getPermission(prompt)
    }

    /// Prompts the user for permission with a yes/no question and requires a yes to proceed.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Throws: `SwiftPickerError.selectionCancelled` if the user does not grant permission.
    func requiredPermission(prompt: String) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}
