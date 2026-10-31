//
//  SwiftPickerError.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Errors thrown by the `required*` picker methods when no input, selection, or permission is given.
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
    /// `getRequiredInput` or `getRequiredSecretInput` received empty input.
    case inputRequired

    /// `requiredSingleSelection` or `requiredTreeNavigation` was cancelled, or `requiredPermission`
    /// was denied.
    case selectionCancelled
}
