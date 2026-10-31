//
//  PickerInterruptBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// What a `SwiftPicker` selection or secret prompt does when SIGINT (Ctrl+C) or SIGTERM ends it
/// and the process keeps running because the host handles the signal itself.
///
/// Either way the terminal is restored first. If the host has no handler, the signal ends the
/// process and this setting never applies.
public enum PickerInterruptBehavior: Sendable {
    /// Finish as if the user quit: optional variants return `nil`, an empty array, or `""`, and
    /// `required*` variants throw `PickerInterruptedError`. The default for `SwiftPicker()`.
    case finishAsCancelled

    /// Block until the process ends instead of returning, so no caller acts on an answer the user
    /// never gave. Covers optional variants too; a further Ctrl+C still reaches the host's handler.
    ///
    /// - Important: Only use this when the host ends the process on every interrupt. If it keeps
    ///   running — a REPL that cancels the current command, for example — the prompt never returns.
    case waitForTermination
}
