//
//  Choose.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    /// Interactive menu to choose which demo to run using SwiftPicker itself.
    ///
    /// This is a meta-demo: it uses SwiftPickerKit to let you choose which SwiftPickerKit
    /// feature to test. It's the easiest way to explore all available modes and layouts
    /// without having to remember command-line flags.
    ///
    /// This pattern (using a picker to navigate your CLI's features) is great for:
    /// - Complex CLI tools with many options
    /// - Interactive setup wizards
    /// - Configuration management tools
    /// - Any scenario where users might not remember all available commands
    ///
    /// Usage:
    ///     swift run SwiftPickerDemo choose
    struct Choose: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "choose",
            abstract: "Interactively choose layout and selection mode using SwiftPicker"
        )

        func run() throws {
            let picker: any CommandLinePicker = SwiftPicker()

            // Define a simple struct conforming to DisplayablePickerItem
            // This demonstrates the minimum required to make any type work with SwiftPicker
            struct Mode: DisplayablePickerItem {
                let name: String
                let description: String
                var displayName: String { name }
            }

            // All available demo combinations
            let modes: [Mode] = [
                .init(
                    name: "Single Column (Single Selection)",
                    description: "Basic single-column UI"
                ),
                .init(
                    name: "Single Column (Multi Selection)",
                    description: "Checkbox-style multi-select"
                ),
                .init(
                    name: "Two Column Static (Single Selection)",
                    description: "Static right panel"
                ),
                .init(
                    name: "Two Column Static (Multi Selection)",
                    description: "Static right panel with multi-select"
                ),
                .init(
                    name: "Two Column Dynamic (Single Selection)",
                    description: "Dynamic detail panel"
                ),
                .init(
                    name: "Two Column Dynamic (Multi Selection)",
                    description: "Dynamic details with multi-select"
                )
            ]

            let prompt = """
            Choose which SwiftPicker layout you want to test.
            This menu exercises all layouts and both selection modes.
            """

            // Use SwiftPicker to let the user choose which demo to run
            guard let selection = picker.singleSelection(
                prompt: prompt,
                items: modes,
                layout: .singleColumn,
                newScreen: true
            ) else {
                print("No choice made.")
                return
            }

            // Route to the appropriate demo based on selection
            switch selection.name {
            case "Single Column (Single Selection)":
                try SwiftPickerDemo.runSingleDemo(
                    layout: .singleColumn,
                    required: false,
                    small: false
                )

            case "Single Column (Multi Selection)":
                SwiftPickerDemo.runMultiDemo(
                    layout: .singleColumn,
                    small: false
                )

            case "Two Column Static (Single Selection)":
                try SwiftPickerDemo.runSingleDemo(
                    layout: .twoColumnStatic(detailText: SwiftPickerDemo.staticDetailText),
                    required: false,
                    small: false
                )

            case "Two Column Static (Multi Selection)":
                SwiftPickerDemo.runMultiDemo(
                    layout: .twoColumnStatic(detailText: SwiftPickerDemo.staticDetailText),
                    small: false
                )

            case "Two Column Dynamic (Single Selection)":
                try SwiftPickerDemo.runDynamicDemo(
                    isMulti: false,
                    small: false
                )

            case "Two Column Dynamic (Multi Selection)":
                try SwiftPickerDemo.runDynamicDemo(
                    isMulti: true,
                    small: false
                )

            default:
                print("Unknown selection.")
            }
        }
    }
}
