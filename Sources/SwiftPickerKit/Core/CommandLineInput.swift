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

    /// Prompts the user for text input without showing what they type.
    ///
    /// Use this for passwords, tokens, and other secrets. Behaves like `getInput(prompt:)`,
    /// except the typed characters are never echoed to the terminal. When standard input is
    /// not a terminal (piped input, CI), the line is read as is.
    ///
    /// Returns an empty string if the user presses Enter without typing anything, or if the
    /// prompt is ended by Ctrl+C or SIGTERM while the host keeps running.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Returns: The user's input (may be empty)
    func getSecretInput(prompt: String) -> String
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

    /// Convenience overload with unlabeled prompt parameter.
    func getSecretInput(_ prompt: String) -> String {
        return getSecretInput(prompt: prompt)
    }

    /// Required variant of `getSecretInput(prompt:)` that throws if the user provides empty input.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Throws: `SwiftPickerError.inputRequired` if input is empty, or
    ///   `PickerInterruptedError` if the prompt is interrupted
    /// - Returns: The user's input (guaranteed non-empty)
    func getRequiredSecretInput(prompt: String) throws -> String {
        let input = getSecretInput(prompt: prompt)
        if input.isEmpty {
            if let interruption = PickerInterruptedError.interruption(for: self) {
                throw interruption
            }

            throw SwiftPickerError.inputRequired
        }
        return input
    }

    /// Required secret input variant with unlabeled prompt parameter.
    ///
    /// - Throws: `SwiftPickerError.inputRequired` if input is empty, or
    ///   `PickerInterruptedError` if the prompt is interrupted
    /// - Returns: The user's input (guaranteed non-empty)
    func getRequiredSecretInput(_ prompt: String) throws -> String {
        return try getRequiredSecretInput(prompt: prompt)
    }
}
