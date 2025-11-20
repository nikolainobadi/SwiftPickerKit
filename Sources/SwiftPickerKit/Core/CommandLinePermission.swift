//
//  CommandLinePermission.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Public interface for permission-style prompts used by `SwiftPicker`.
public protocol CommandLinePermission {
    /// Prompts the user for permission with a yes/no question.
    func getPermission(prompt: String) -> Bool
}


// MARK: - CommandLinePermission Convenience
public extension CommandLinePermission {
    func getPermission(_ prompt: String) -> Bool {
        return getPermission(prompt: prompt)
    }

    func requiredPermission(prompt: String) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }

    func requiredPermission(_ prompt: String) throws {
        try requiredPermission(prompt: prompt)
    }
}
