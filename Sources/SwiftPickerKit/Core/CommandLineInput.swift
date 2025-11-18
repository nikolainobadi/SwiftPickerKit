//
//  CommandLineInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Public interface for text-based input handling used by `SwiftPicker`.
public protocol CommandLineInput {
    /// Prompts the user for input with the given prompt string.
    func getInput(prompt: String) -> String

    /// Prompts the user for input with the given prompt string and requires input.
    func getRequiredInput(prompt: String) throws -> String
}
