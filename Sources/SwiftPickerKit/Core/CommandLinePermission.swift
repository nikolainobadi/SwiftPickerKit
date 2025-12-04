//
//  CommandLinePermission.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Public interface for permission-style prompts used by `SwiftPicker`.
///
/// Permission prompts are yes/no questions commonly used for:
/// - Confirming destructive operations
/// - Asking for user consent
/// - Validating user understanding
/// - Proceeding with optional actions
///
/// ## Usage
///
/// ```swift
/// let picker = SwiftPicker()
///
/// // Optional permission (returns false if user says no)
/// if picker.getPermission(prompt: "Continue with installation?") {
///     performInstallation()
/// } else {
///     print("Installation cancelled")
/// }
///
/// // Required permission (throws if user says no)
/// do {
///     try picker.requiredPermission(prompt: "Do you understand this is irreversible?")
///     performDestructiveOperation()
/// } catch {
///     print("User did not confirm")
/// }
/// ```
public protocol CommandLinePermission {
    /// Prompts the user for permission with a yes/no question.
    ///
    /// Displays the prompt and waits for the user to respond. Typically accepts
    /// 'y'/'yes' for true and 'n'/'no' for false (implementation-specific).
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

    /// Required permission variant that throws if the user denies permission.
    ///
    /// Use this when permission is mandatory for your workflow. If the user responds
    /// with 'no', this method throws `SwiftPickerError.selectionCancelled`.
    ///
    /// - Parameter prompt: The question to ask the user
    /// - Throws: `SwiftPickerError.selectionCancelled` if user denies permission
    func requiredPermission(prompt: String) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }

    /// Required permission variant with unlabeled prompt parameter.
    ///
    /// - Throws: `SwiftPickerError.selectionCancelled` if user denies permission
    func requiredPermission(_ prompt: String) throws {
        try requiredPermission(prompt: prompt)
    }
}
