//
//  PickerInterruptedError.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

/// Thrown when a required prompt on a `SwiftPicker` is ended by SIGINT (Ctrl+C) or SIGTERM, rather
/// than cancelled by the user, while the host handles the signal and keeps running.
///
/// Thrown by `requiredSingleSelection`, `requiredTreeNavigation`, `getRequiredSecretInput`, and the
/// `flagHint:` variants of `requiredSingleSelection`, `requiredMultiSelection`, and
/// `requiredTreeNavigation`. Types that wrap a `SwiftPicker` throw their usual cancellation error
/// instead, and optional variants still return `nil`, an empty array, or `""`.
///
/// A separate type because adding a case to the public `SwiftPickerError` enum would break
/// downstream exhaustive `switch`es.
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
    /// An error when `picker` is a `SwiftPicker` whose most recent prompt was ended by SIGINT or
    /// SIGTERM; `nil` otherwise, so mocks and `NonInteractivePicker` never report an interrupt.
    static func interruption(for picker: Any) -> PickerInterruptedError? {
        guard picker is SwiftPicker, SignalHandler.wasInterrupted else {
            return nil
        }

        return PickerInterruptedError()
    }
}
