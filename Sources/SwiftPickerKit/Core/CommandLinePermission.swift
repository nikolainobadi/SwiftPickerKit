//
//  CommandLinePermission.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Yes/no confirmation prompts.
///
/// ```swift
/// if picker.getPermission(prompt: "Continue with installation?") {
///     performInstallation()
/// }
///
/// do {
///     try picker.requiredPermission(prompt: "Do you understand this is irreversible?")
///     performDestructiveOperation()
/// } catch {
///     print("User did not confirm")
/// }
/// ```
public protocol CommandLinePermission {
    /// Asks a yes/no question; accepted answers (typically `y`/`yes`, `n`/`no`) depend on the conformer.
    ///
    /// - Parameter prompt: The question to ask the user
    /// - Returns: `true` if the user grants permission, `false` if denied
    func getPermission(prompt: String) -> Bool
}

// MARK: - CommandLinePermission Convenience

public extension CommandLinePermission {
    /// Convenience overload with unlabeled prompt parameter.
    func getPermission(_ prompt: String) -> Bool {
        return getPermission(prompt: prompt)
    }

    /// Asks a yes/no question and throws unless the user answers yes.
    ///
    /// - Parameter prompt: The question to ask the user
    /// - Throws: `SwiftPickerError.selectionCancelled` if the user denies permission
    func requiredPermission(prompt: String) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }

    /// Convenience overload of `requiredPermission(prompt:)` with unlabeled prompt parameter.
    ///
    /// - Throws: `SwiftPickerError.selectionCancelled` if the user denies permission
    func requiredPermission(_ prompt: String) throws {
        try requiredPermission(prompt: prompt)
    }
}
