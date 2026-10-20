//
//  PickerInterruptedError.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

/// Thrown when a required selection is ended by SIGINT (Ctrl+C) or SIGTERM rather than by the
/// user cancelling.
///
/// Only reached when the host application handles the signal itself and the process keeps
/// running; with no handler of its own, the process ends by the signal instead. Lets a caller
/// stop its workflow rather than treat the prompt as answered with nothing.
///
/// Thrown by `requiredSingleSelection`, `requiredTreeNavigation`, and the `flagHint:` variants of
/// `requiredSingleSelection`, `requiredMultiSelection`, and `requiredTreeNavigation`, when called
/// on a `SwiftPicker`. A custom type that wraps a `SwiftPicker` throws its usual cancellation
/// error instead. The optional variants still return `nil` or an empty array.
///
/// A separate type rather than a `SwiftPickerError` case: adding a case to that public enum would
/// break downstream exhaustive `switch`es.
///
/// ```swift
/// do {
///     let target = try picker.requiredSingleSelection(prompt: "Choose a target", items: targets)
/// } catch is PickerInterruptedError {
///     return  // the host is shutting down; don't carry on
/// }
/// ```
public struct PickerInterruptedError: Error, Equatable, LocalizedError {
    public init() {}

    public var errorDescription: String? {
        return "The prompt was interrupted."
    }
}

// MARK: - Interruption
extension PickerInterruptedError {
    /// An error when `picker` is a `SwiftPicker` whose most recent selection prompt was ended by
    /// SIGINT or SIGTERM; `nil` otherwise.
    ///
    /// Only `SwiftPicker` runs prompts under the signal handler, so other conformers — mocks,
    /// `NonInteractivePicker` — never report an interrupt, even after one elsewhere in the process.
    static func interruption(for picker: Any) -> PickerInterruptedError? {
        guard picker is SwiftPicker, SignalHandler.wasInterrupted else {
            return nil
        }

        return PickerInterruptedError()
    }
}
