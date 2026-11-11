//
//  PermissionSubmitMode.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/11/26.
//

/// How a `SwiftPicker` permission prompt accepts the user's `y`/`n` answer.
public enum PermissionSubmitMode: Sendable {
    /// The user types an answer and presses Enter. Only `y` or `Y` counts as yes. An empty
    /// answer asks again, up to twice, before it counts as no. The default for `SwiftPicker()`.
    case requireEnter

    /// The answer is taken as soon as `y`/`Y` or `n`/`N` is pressed, without Enter. Other keys
    /// are ignored. If an interrupt ends the prompt, it returns no.
    ///
    /// When standard input is not a terminal (piped input, CI), the prompt falls back to
    /// `requireEnter`, because a pipe has no keypresses to read.
    case immediate
}
