//
//  MockTextInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

@testable import SwiftPickerKit

final class MockTextInput: TextInput {
    private var inputResponses: [String]
    private var secretResponses: [String]
    private let onSecretRead: () -> Void
    private var permissionResponses: [Bool]

    private(set) var capturedInputPrompts: [String] = []
    private(set) var capturedSecretPrompts: [String] = []
    private(set) var capturedPermissionPrompts: [String] = []

    /// - Parameter onSecretRead: Runs inside the signal-handling window a real secret read opens,
    ///   so a test can deliver a signal mid-read
    init(inputResponses: [String] = [], secretResponses: [String] = [], permissionResponses: [Bool] = [], onSecretRead: @escaping () -> Void = {}) {
        self.inputResponses = inputResponses
        self.secretResponses = secretResponses
        self.onSecretRead = onSecretRead
        self.permissionResponses = permissionResponses
    }

    func getInput(_ prompt: String) -> String {
        capturedInputPrompts.append(prompt)
        guard !inputResponses.isEmpty else { return "" }
        return inputResponses.removeFirst()
    }

    /// Mirrors `DefaultTextInput`: each secret read runs under fresh signal handlers, which also
    /// clears any interrupt left over from an earlier prompt.
    func getSecretInput(_ prompt: String) -> String {
        capturedSecretPrompts.append(prompt)
        SignalHandler.setupSignalHandlers(cleanup: {})
        defer { SignalHandler.removeSignalHandlers() }
        onSecretRead()
        guard !secretResponses.isEmpty else { return "" }
        return secretResponses.removeFirst()
    }

    func getPermission(_ prompt: String) -> Bool {
        capturedPermissionPrompts.append(prompt)
        guard !permissionResponses.isEmpty else { return true }
        return permissionResponses.removeFirst()
    }
}
