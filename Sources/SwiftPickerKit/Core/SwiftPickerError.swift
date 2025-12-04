//
//  SwiftPickerError.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Errors that can be thrown by SwiftPicker operations.
///
/// These errors are primarily thrown by "required" variants of picker methods
/// when mandatory input or selections are not provided.
///
/// ## Usage Example
///
/// ```swift
/// do {
///     let selection = try picker.requiredSingleSelection(
///         prompt: "Choose a language",
///         items: languages
///     )
///     print("Selected: \(selection.displayName)")
/// } catch SwiftPickerError.selectionCancelled {
///     print("User cancelled the selection")
/// }
/// ```
public enum SwiftPickerError: Error {
    /// Thrown when `getRequiredInput` receives empty input.
    ///
    /// Use this error to enforce that users provide non-empty text input.
    /// The standard `getInput` method returns empty strings without throwing.
    case inputRequired

    /// Thrown when a required selection or permission is cancelled by the user.
    ///
    /// This occurs when:
    /// - `requiredSingleSelection` is cancelled (user presses 'q' or Ctrl+C)
    /// - `requiredTreeNavigation` is cancelled
    /// - `requiredPermission` is denied (user selects 'no')
    ///
    /// The optional variants (`singleSelection`, `treeNavigation`, `getPermission`)
    /// return nil or false instead of throwing.
    case selectionCancelled
}
