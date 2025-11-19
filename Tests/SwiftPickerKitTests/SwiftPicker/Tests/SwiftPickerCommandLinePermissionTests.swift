//
//  SwiftPickerCommandLinePermissionTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLinePermissionTests {
    @Test("CommandLinePermission getPermission returns configured response")
    func commandLinePermissionGetPermissionReturnsConfiguredResponse() {
        let expectedResponse = false
        let prompt = "Delete project?"
        let (sut, textInput) = makeSUT(permissionResponses: [expectedResponse])
        let commandLinePermission: CommandLinePermission = sut

        let result = commandLinePermission.getPermission(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedPermissionPrompts == [prompt])
    }

    @Test("CommandLinePermission requiredPermission completes when granted")
    func commandLinePermissionRequiredPermissionCompletesWhenGranted() throws {
        let (sut, _) = makeSUT(permissionResponses: [true])
        let commandLinePermission: CommandLinePermission = sut

        try commandLinePermission.requiredPermission(prompt: "Proceed?")
    }

    @Test("CommandLinePermission requiredPermission throws when denied")
    func commandLinePermissionRequiredPermissionThrowsWhenDenied() {
        let (sut, _) = makeSUT(permissionResponses: [false])
        let commandLinePermission: CommandLinePermission = sut

        #expect(throws: SwiftPickerError.self) {
            try commandLinePermission.requiredPermission(prompt: "Proceed?")
        }
    }
}


// MARK: - Test Doubles
private final class PermissionStubTextInput: TextInput {
    private var permissionResponses: [Bool]
    private(set) var capturedPermissionPrompts: [String] = []

    init(permissionResponses: [Bool]) {
        self.permissionResponses = permissionResponses
    }

    func getInput(_ prompt: String) -> String {
        return ""
    }

    func getPermission(_ prompt: String) -> Bool {
        capturedPermissionPrompts.append(prompt)
        guard !permissionResponses.isEmpty else { return true }
        return permissionResponses.removeFirst()
    }
}


private struct NoOpPickerInput: PickerInput {
    func cursorOff() {}
    func moveRight() {}
    func moveToHome() {}
    func clearBuffer() {}
    func clearScreen() {}
    func enableNormalInput() {}
    func keyPressed() -> Bool { false }
    func write(_ text: String) {}
    func exitAlternativeScreen() {}
    func enterAlternativeScreen() {}
    func moveTo(_ row: Int, _ col: Int) {}
    func readDirectionKey() -> Direction? { nil }
    func readSpecialChar() -> SpecialChar? { nil }
    func readCursorPos() -> (row: Int, col: Int) { (0, 0) }
    func readScreenSize() -> (rows: Int, cols: Int) { (0, 0) }
}


// MARK: - Helpers
private func makeSUT(permissionResponses: [Bool]) -> (SwiftPicker, PermissionStubTextInput) {
    let textInput = PermissionStubTextInput(permissionResponses: permissionResponses)
    let sut = SwiftPicker(textInput: textInput, pickerInput: NoOpPickerInput())
    return (sut, textInput)
}
