//
//  PickerRequirementErrorTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Testing
@testable import SwiftPickerKit

struct PickerRequirementErrorTests {
    @Test
    func `A missing value names the flag that supplies it`() {
        let sut = makeSUT(.input, prompt: "Project name", flagHint: "--name")

        #expect(sut.errorDescription == "Missing required value for \"Project name\". Pass --name.")
    }

    @Test
    func `A missing selection names the flag that supplies it`() {
        let sut = makeSUT(.selection, prompt: "Choose a target", flagHint: "--target")

        #expect(sut.errorDescription == "No selection made for \"Choose a target\". Pass --target.")
    }

    @Test
    func `A denied confirmation names the flag that grants it`() {
        let sut = makeSUT(.confirmation, prompt: "Delete all builds?", flagHint: "--force")

        #expect(sut.errorDescription == "Confirmation required for \"Delete all builds?\". Pass --force.")
    }
}

// MARK: - Unnamed Flags
extension PickerRequirementErrorTests {
    @Test
    func `A missing value asks for an argument when no flag is named`() {
        let sut = makeSUT(.input, prompt: "Project name", flagHint: nil)

        #expect(sut.errorDescription == "Missing required value for \"Project name\". Provide it as an argument.")
    }

    @Test
    func `A missing selection asks for an argument when no flag is named`() {
        let sut = makeSUT(.selection, prompt: "Choose a target", flagHint: nil)

        #expect(sut.errorDescription == "No selection made for \"Choose a target\". Provide it as an argument.")
    }

    @Test
    func `A denied confirmation falls back to the standard consent flag when none is named`() {
        let sut = makeSUT(.confirmation, prompt: "Delete all builds?", flagHint: nil)

        #expect(sut.errorDescription == "Confirmation required for \"Delete all builds?\". Pass --yes.")
    }
}


// MARK: - Helpers
private extension PickerRequirementErrorTests {
    enum Requirement {
        case input, selection, confirmation
    }
}


// MARK: - SUT
private extension PickerRequirementErrorTests {
    func makeSUT(_ requirement: Requirement = .input, prompt: String = "Project name", flagHint: String? = "--name") -> PickerRequirementError {
        switch requirement {
        case .input:
            return .missingInput(prompt: prompt, flagHint: flagHint)
        case .selection:
            return .missingSelection(prompt: prompt, flagHint: flagHint)
        case .confirmation:
            return .confirmationRequired(prompt: prompt, flagHint: flagHint)
        }
    }
}
