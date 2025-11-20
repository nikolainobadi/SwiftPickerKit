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
}


// MARK: - CommandLineInput Convenience
public extension CommandLineInput {
    func getInput(_ prompt: String) -> String {
        return getInput(prompt: prompt)
    }
    
    func getRequiredInput(prompt: String) throws -> String {
        let input = getInput(prompt: prompt)
        if input.isEmpty {
            throw SwiftPickerError.inputRequired
        }
        return input
    }

    func getRequiredInput(_ prompt: String) throws -> String {
        return try getRequiredInput(prompt: prompt)
    }
}
