//
//  CommandLinePicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Unified protocol combining all SwiftPicker command-line interaction APIs.
///
/// `CommandLinePicker` is a typealias that combines all four core SwiftPicker protocols:
/// - `CommandLineInput` — Text input prompts
/// - `CommandLinePermission` — Yes/no confirmation prompts
/// - `CommandLineSelection` — Single and multi-selection pickers
/// - `CommandLineTreeNavigation` — Hierarchical tree navigation
///
/// ## Usage
///
/// When you want to accept any type that provides all SwiftPicker functionality,
/// use `CommandLinePicker` as a constraint:
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
///
/// `SwiftPicker` is the standard implementation that conforms to `CommandLinePicker`.
public typealias CommandLinePicker = CommandLineInput
    & CommandLinePermission
    & CommandLineSelection
    & CommandLineTreeNavigation
