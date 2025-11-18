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

    /// Prompts the user for permission and requires `true` to continue.
    func requiredPermission(prompt: String) throws
}
