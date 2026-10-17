//
//  PickerInterruptBehavior.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// What a `SwiftPicker` selection prompt does when SIGINT (Ctrl+C) or SIGTERM ends it and the
/// process keeps running because the host application handles the signal itself.
///
/// Either way the terminal is restored first. With no handler of its own, the host never sees
/// this choice: the process ends by the signal.
public enum PickerInterruptBehavior: Sendable {
    /// Finish as if the user pressed the quit key: the optional variants return `nil` or an empty
    /// array, and the `required*` variants throw `PickerInterruptedError`. What `SwiftPicker()` uses.
    case finishAsCancelled

    /// Block until the process ends instead of returning.
    ///
    /// For hosts whose interrupt handling always ends the process, so no caller acts on a `nil` or
    /// empty answer that the user never gave. Covers every selection variant, including the
    /// optional ones, without callers checking anything. A further Ctrl+C still reaches the
    /// host's handler.
    ///
    /// - Important: Only use this when the host ends the process on every interrupt. If it keeps
    ///   running — a REPL that cancels the current command, for example — the prompt never returns.
    case waitForTermination
}
