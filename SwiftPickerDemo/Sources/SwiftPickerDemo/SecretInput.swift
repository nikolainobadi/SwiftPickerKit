//
//  SecretInput.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 10/31/26.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    /// Demonstrates secret (no-echo) text input for passwords and tokens.
    ///
    /// What the user types never appears on screen. Pressing Ctrl+C mid-prompt still leaves the
    /// shell echoing normally afterwards.
    ///
    /// Usage:
    ///     swift run SwiftPickerDemo secret [--required]
    ///
    /// Examples:
    ///     swift run SwiftPickerDemo secret
    ///     swift run SwiftPickerDemo secret --required
    ///     echo hunter2 | swift run SwiftPickerDemo secret
    struct SecretInput: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "secret",
            abstract: "Test secret (no-echo) text input"
        )

        @Flag(name: .shortAndLong, help: "Require a secret and throw if none is entered")
        var required = false

        func run() throws {
            let picker = SwiftPicker()
            let prompt = "Enter a password (it won't be shown):"

            let secret: String
            if required {
                // getRequiredSecretInput throws if the secret is empty or the prompt is interrupted
                secret = try picker.getRequiredSecretInput(prompt: prompt)
            } else {
                secret = picker.getSecretInput(prompt: prompt)
            }

            if secret.isEmpty {
                print("No secret entered")
            } else {
                // Never print a real secret; the length is enough to confirm it was read
                print("Read a secret of \(secret.count) character(s)")
            }
        }
    }
}
