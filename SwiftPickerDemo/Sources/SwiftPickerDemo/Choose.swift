//
//  Choose.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    struct Choose: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "choose",
            abstract: "Interactively choose layout and selection mode using SwiftPicker"
        )

        func run() throws {
            let picker: any CommandLinePicker = SwiftPicker()

            struct Mode: DisplayablePickerItem {
                let name: String
                let description: String
                var displayName: String { name }
            }

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

            guard let selection = picker.singleSelection(
                prompt: prompt,
                items: modes,
                layout: .singleColumn,
                newScreen: true
            ) else {
                print("No choice made.")
                return
            }

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
