//
//  PickerRequirementError.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Foundation

/// Errors thrown by the `flagHint:` variants of the `required*` picker methods.
///
/// These variants exist so a failed prompt can tell the user which command line flag to pass
/// instead. The messages are deliberately **mode-neutral**: the same overloads fire when a live
/// `SwiftPicker` receives empty input or a cancelled selection, so the text has to read correctly
/// whether or not the run was interactive.
///
/// This is a separate type from `SwiftPickerError` on purpose. `SwiftPickerError` is a public
/// enum in a package without library evolution, so adding a case to it would break any client
/// that switches over it exhaustively.
///
/// ## Usage
///
/// ```swift
/// do {
///     let name = try picker.getRequiredInput(prompt: "Project name", flagHint: "--name")
///     print(name)
/// } catch let error as PickerRequirementError {
///     // "Missing required value for "Project name". Pass --name."
///     print(error.localizedDescription)
/// }
/// ```
public enum PickerRequirementError: Error, LocalizedError {
    /// Thrown when a required text prompt produced empty input.
    case missingInput(prompt: String, flagHint: String?)

    /// Thrown when a required selection or tree navigation produced no result.
    case missingSelection(prompt: String, flagHint: String?)

    /// Thrown when a required permission prompt was denied.
    case confirmationRequired(prompt: String, flagHint: String?)

    public var errorDescription: String? {
        switch self {
        case .missingInput(let prompt, let flagHint):
            return "Missing required value for \"\(prompt)\". \(Self.remedy(flagHint))"
        case .missingSelection(let prompt, let flagHint):
            return "No selection made for \"\(prompt)\". \(Self.remedy(flagHint))"
        case .confirmationRequired(let prompt, let flagHint):
            return "Confirmation required for \"\(prompt)\". \(Self.remedy(flagHint ?? "--yes"))"
        }
    }
}


// MARK: - Private Helpers
private extension PickerRequirementError {
    /// Renders the "here's how to fix it" half of the message.
    static func remedy(_ flagHint: String?) -> String {
        guard let flagHint else {
            return "Provide it as an argument."
        }

        return "Pass \(flagHint)."
    }
}
