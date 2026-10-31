//
//  CommandLinePicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// All four picker protocols in one: `CommandLineInput`, `CommandLinePermission`,
/// `CommandLineSelection`, and `CommandLineTreeNavigation`.
///
/// Conformers include `SwiftPicker`, `NonInteractivePicker`, and `MockSwiftPicker`.
///
/// ```swift
/// func setupWizard(picker: any CommandLinePicker) {
///     let name = picker.getInput(prompt: "Enter your name:")
///
///     if picker.getPermission(prompt: "Continue?") {
///         let language = picker.singleSelection(
///             prompt: "Choose a language",
///             items: ["Swift", "Python", "JavaScript"]
///         )
///     }
/// }
/// ```
public typealias CommandLinePicker = CommandLineInput
    & CommandLinePermission
    & CommandLineSelection
    & CommandLineTreeNavigation
