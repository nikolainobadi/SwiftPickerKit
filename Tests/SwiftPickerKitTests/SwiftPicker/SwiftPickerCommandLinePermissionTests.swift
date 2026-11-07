//
//  SwiftPickerCommandLinePermissionTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Testing
@testable import SwiftPickerKit

struct SwiftPickerCommandLinePermissionTests {
    @Test
    func `Starting values empty`() {
        let (_, textInput) = makeSUT(inputResponses: [], permissionResponses: [], assumeYes: false)
        #expect(textInput.capturedPermissionPrompts.isEmpty)
    }

    @Test
    func `Returns configured response when permission requested`() {
        let expectedResponse = false
        let prompt = "Delete project?"
        let (sut, textInput) = makeSUT(inputResponses: [], permissionResponses: [expectedResponse], assumeYes: false)
        let commandLinePermission: CommandLinePermission = sut

        let result = commandLinePermission.getPermission(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedPermissionPrompts == [prompt])
    }

    @Test
    func `Completes successfully when required permission is granted`() throws {
        let (sut, _) = makeSUT(inputResponses: [], permissionResponses: [true], assumeYes: false)
        let commandLinePermission: CommandLinePermission = sut

        try commandLinePermission.requiredPermission(prompt: "Proceed?")
    }

    @Test
    func `Throws error when required permission is denied`() {
        let (sut, _) = makeSUT(inputResponses: [], permissionResponses: [false], assumeYes: false)
        let commandLinePermission: CommandLinePermission = sut

        #expect(throws: SwiftPickerError.self) {
            try commandLinePermission.requiredPermission(prompt: "Proceed?")
        }
    }
}

// MARK: - Assume Yes
extension SwiftPickerCommandLinePermissionTests {
    @Test
    func `Grants permission without asking when assuming yes`() {
        let (sut, textInput) = makeSUT(inputResponses: [], permissionResponses: [false], assumeYes: true)
        let commandLinePermission: CommandLinePermission = sut

        let result = commandLinePermission.getPermission(prompt: "Delete project?")

        #expect(result)
        #expect(textInput.capturedPermissionPrompts.isEmpty)
    }

    @Test
    func `Required permission does not throw when assuming yes`() throws {
        let (sut, textInput) = makeSUT(inputResponses: [], permissionResponses: [false], assumeYes: true)
        let commandLinePermission: CommandLinePermission = sut

        try commandLinePermission.requiredPermission(prompt: "Proceed?")

        #expect(textInput.capturedPermissionPrompts.isEmpty)
    }

    @Test
    func `Required permission with flag hint does not throw when assuming yes`() throws {
        let (sut, textInput) = makeSUT(inputResponses: [], permissionResponses: [false], assumeYes: true)
        let commandLinePermission: CommandLinePermission = sut

        try commandLinePermission.requiredPermission(prompt: "Proceed?", flagHint: "--force")

        #expect(textInput.capturedPermissionPrompts.isEmpty)
    }

    @Test
    func `Text input still prompts when assuming yes`() {
        let prompt = "Enter project name"
        let expectedResponse = "SwiftPicker"
        let (sut, textInput) = makeSUT(inputResponses: [expectedResponse], permissionResponses: [], assumeYes: true)

        let result = sut.getInput(prompt: prompt)

        #expect(result == expectedResponse)
        #expect(textInput.capturedInputPrompts == [prompt])
    }
}

// MARK: - SUT
private extension SwiftPickerCommandLinePermissionTests {
    func makeSUT(inputResponses: [String], permissionResponses: [Bool], assumeYes: Bool) -> (SwiftPicker, MockTextInput) {
        let textInput = MockTextInput(inputResponses: inputResponses, permissionResponses: permissionResponses)
        let sut = SwiftPicker(textInput: textInput, pickerInput: MockPickerInput(), waitForTermination: nil, assumeYes: assumeYes)
        return (sut, textInput)
    }
}
