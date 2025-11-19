//
//  MockTextInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

@testable import SwiftPickerKit

final class MockTextInput: TextInput {
    private var inputResponses: [String]
    private var permissionResponses: [Bool]

    private(set) var capturedInputPrompts: [String] = []
    private(set) var capturedPermissionPrompts: [String] = []

    init(inputResponses: [String] = [], permissionResponses: [Bool] = []) {
        self.inputResponses = inputResponses
        self.permissionResponses = permissionResponses
    }

    func getInput(_ prompt: String) -> String {
        capturedInputPrompts.append(prompt)
        guard !inputResponses.isEmpty else { return "" }
        return inputResponses.removeFirst()
    }

    func getPermission(_ prompt: String) -> Bool {
        capturedPermissionPrompts.append(prompt)
        guard !permissionResponses.isEmpty else { return true }
        return permissionResponses.removeFirst()
    }
}
