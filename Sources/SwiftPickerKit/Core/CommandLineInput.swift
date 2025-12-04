//
//  CommandLineInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Public interface for text-based input handling used by `SwiftPicker`.
///
/// This protocol provides methods for prompting users to enter text input.
/// Unlike picker-based interfaces, text input uses standard terminal readline
/// behavior where users type freely and press Enter to submit.
///
/// ## Usage
///
/// ```swift
/// let picker = SwiftPicker()
///
/// // Optional input (returns empty string if user just presses Enter)
/// let name = picker.getInput(prompt: "Enter your name (optional):")
///
/// // Required input (throws if empty)
/// do {
///     let email = try picker.getRequiredInput(prompt: "Enter your email:")
///     print("Email: \(email)")
/// } catch SwiftPickerError.inputRequired {
///     print("Email is required")
/// }
/// ```
public protocol CommandLineInput {
    /// Prompts the user for text input.
    ///
    /// Displays the prompt and waits for the user to type input and press Enter.
    /// Returns an empty string if the user presses Enter without typing anything.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Returns: The user's input (may be empty)
    func getInput(prompt: String) -> String
}


// MARK: - CommandLineInput Convenience

public extension CommandLineInput {
    /// Convenience overload with unlabeled prompt parameter.
    func getInput(_ prompt: String) -> String {
        return getInput(prompt: prompt)
    }

    /// Required input variant that throws if the user provides empty input.
    ///
    /// Use this when input is mandatory for your workflow. If the user presses Enter
    /// without typing anything, this method throws `SwiftPickerError.inputRequired`.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Throws: `SwiftPickerError.inputRequired` if input is empty
    /// - Returns: The user's input (guaranteed non-empty)
    func getRequiredInput(prompt: String) throws -> String {
        let input = getInput(prompt: prompt)
        if input.isEmpty {
            throw SwiftPickerError.inputRequired
        }
        return input
    }

    /// Required input variant with unlabeled prompt parameter.
    ///
    /// - Throws: `SwiftPickerError.inputRequired` if input is empty
    /// - Returns: The user's input (guaranteed non-empty)
    func getRequiredInput(_ prompt: String) throws -> String {
        return try getRequiredInput(prompt: prompt)
    }
}
