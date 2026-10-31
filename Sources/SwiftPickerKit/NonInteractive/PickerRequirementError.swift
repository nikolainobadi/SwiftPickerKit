//
//  PickerRequirementError.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Foundation

/// Errors thrown by the `flagHint:` variants of the `required*` methods, naming the command line
/// flag to pass instead.
///
/// Messages are mode-neutral, since the same overloads fail on a live `SwiftPicker` too. A
/// separate type because adding cases to the public `SwiftPickerError` enum would break
/// downstream exhaustive `switch`es.
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
    /// A required text prompt produced empty input.
    case missingInput(prompt: String, flagHint: String?)

    /// A required selection or tree navigation produced no result.
    case missingSelection(prompt: String, flagHint: String?)

    /// A required permission prompt was denied; the message suggests `--yes` if `flagHint` is `nil`.
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
    /// The "how to fix it" half of the message.
    static func remedy(_ flagHint: String?) -> String {
        guard let flagHint else {
            return "Provide it as an argument."
        }

        return "Pass \(flagHint)."
    }
}
