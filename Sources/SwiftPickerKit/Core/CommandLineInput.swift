//
//  CommandLineInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Line-based text prompts: the user types freely and presses Enter to submit.
///
/// ```swift
/// let name = picker.getInput(prompt: "Enter your name (optional):")  // "" if skipped
///
/// do {
///     let email = try picker.getRequiredInput(prompt: "Enter your email:")
///     print("Email: \(email)")
/// } catch SwiftPickerError.inputRequired {
///     print("Email is required")
/// }
/// ```
public protocol CommandLineInput {
    /// Prompts for a line of text.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Returns: The user's input, or `""` if they press Enter without typing
    func getInput(prompt: String) -> String

    /// Prompts for a line of text without echoing it, for passwords, tokens, and other secrets.
    ///
    /// When standard input is not a terminal (piped input, CI), the line is read as is. On
    /// `SwiftPicker`, a prompt ended by Ctrl+C or SIGTERM while the host keeps running returns
    /// `""`, or blocks under `PickerInterruptBehavior.waitForTermination`.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Returns: The user's input, or `""` if empty or interrupted
    func getSecretInput(prompt: String) -> String
}

// MARK: - CommandLineInput Convenience

public extension CommandLineInput {
    /// Convenience overload with unlabeled prompt parameter.
    func getInput(_ prompt: String) -> String {
        return getInput(prompt: prompt)
    }

    /// Prompts for a line of text and throws if it is empty.
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

    /// Convenience overload of `getRequiredInput(prompt:)` with unlabeled prompt parameter.
    ///
    /// - Throws: `SwiftPickerError.inputRequired` if input is empty
    func getRequiredInput(_ prompt: String) throws -> String {
        return try getRequiredInput(prompt: prompt)
    }

    /// Convenience overload with unlabeled prompt parameter.
    func getSecretInput(_ prompt: String) -> String {
        return getSecretInput(prompt: prompt)
    }

    /// Prompts for a secret like `getSecretInput(prompt:)` and throws if the answer is empty.
    ///
    /// - Parameter prompt: The prompt text to display
    /// - Throws: `PickerInterruptedError` if a `SwiftPicker` prompt is ended by Ctrl+C or SIGTERM
    ///   while the host keeps running; otherwise `SwiftPickerError.inputRequired` if input is empty
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

    /// Convenience overload of `getRequiredSecretInput(prompt:)` with unlabeled prompt parameter.
    ///
    /// - Throws: `PickerInterruptedError` if interrupted while the host keeps running;
    ///   otherwise `SwiftPickerError.inputRequired` if input is empty
    func getRequiredSecretInput(_ prompt: String) throws -> String {
        return try getRequiredSecretInput(prompt: prompt)
    }
}
