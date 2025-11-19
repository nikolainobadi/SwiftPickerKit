//
//  SwiftPickerCommandLinePermissionTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLinePermissionTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, textInput) = makeSUT(permissionResponses: [])
        #expect(textInput.capturedPermissionPrompts.isEmpty)
    }

    @Test("Returns configured response when permission requested")
    func returnsConfiguredResponseWhenPermissionRequested() {
        let expectedResponse = false
        let prompt = "Delete project?"
        let (sut, textInput) = makeSUT(permissionResponses: [expectedResponse])
        let commandLinePermission: CommandLinePermission = sut

        let result = commandLinePermission.getPermission(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedPermissionPrompts == [prompt])
    }

    @Test("Completes successfully when required permission is granted")
    func completesSuccessfullyWhenRequiredPermissionIsGranted() throws {
        let (sut, _) = makeSUT(permissionResponses: [true])
        let commandLinePermission: CommandLinePermission = sut

        try commandLinePermission.requiredPermission(prompt: "Proceed?")
    }

    @Test("Throws error when required permission is denied")
    func throwsErrorWhenRequiredPermissionIsDenied() {
        let (sut, _) = makeSUT(permissionResponses: [false])
        let commandLinePermission: CommandLinePermission = sut

        #expect(throws: SwiftPickerError.self) {
            try commandLinePermission.requiredPermission(prompt: "Proceed?")
        }
    }
}


// MARK: - Helpers
private func makeSUT(permissionResponses: [Bool]) -> (SwiftPicker, MockTextInput) {
    let textInput = MockTextInput(permissionResponses: permissionResponses)
    let sut = SwiftPicker(textInput: textInput, pickerInput: MockPickerInput())
    return (sut, textInput)
}
