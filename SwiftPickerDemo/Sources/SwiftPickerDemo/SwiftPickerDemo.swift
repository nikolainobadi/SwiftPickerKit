//
//  SwiftPickerDemo.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation
import ArgumentParser
import SwiftPickerKit

@main
struct SwiftPickerDemo: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Test tool for SwiftPickerKit",
        subcommands: [
            SingleSelection.self,
            MultiSelection.self,
            DynamicDetail.self,
            Choose.self,
            Browse.self
        ]
    )
}

// MARK: - Shared helpers

extension SwiftPickerDemo {

    private static var singlePrompt: String {
        """
        Choose your favorite language to personalize your experience.
        Your choice helps tailor future suggestions, examples, and project
        templates based on what you prefer most.
        """
    }

    private static var multiPrompt: String {
        """
        Select any languages you work with regularly.
        Your selections help build a customized toolkit, feature set,
        and workflow recommendations tuned to you.
        """
    }

    private static var staticDetailText: String {
        """
        This is my own custom detail text.

        The purpose of this text is to give more information
        to the user as they use my awesome new tool.

        This text is static, so it should remain the same
        regardless of which item in the first column is
        currently selected.
        """
    }

    static func runSingleDemo(
        layout: PickerLayout<TestItem>,
        required: Bool,
        small: Bool
    ) throws {
        let picker = SwiftPicker()
        let items = small ? TestItem.smallList : TestItem.largeList
        let prompt = singlePrompt

        if required {
            let selection = try picker.requiredSingleSelection(
                prompt: prompt,
                items: items,
                layout: layout,
                newScreen: true,
                showSelectedItemText: true
            )

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        } else {
            guard let selection = picker.singleSelection(
                prompt: prompt,
                items: items,
                layout: layout,
                newScreen: true
            ) else {
                print("\nNo selection made")
                return
            }

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        }
    }

    static func runMultiDemo(
        layout: PickerLayout<TestItem>,
        small: Bool
    ) {
        let picker = SwiftPicker()
        let items = small ? TestItem.smallList : TestItem.largeList
        let prompt = multiPrompt

        let selections = picker.multiSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            newScreen: true
        )

        if selections.isEmpty {
            print("\nNo selections made")
        } else {
            print("\nYou selected \(selections.count) item(s):")
            selections.forEach { item in
                print(" • \(item.displayName)")
            }
        }
    }

    static func runDynamicDemo(
        isMulti: Bool,
        small: Bool
    ) throws {
        let picker = SwiftPicker()
        let items = small ? Array(TestItem.dynamicList.prefix(4)) : TestItem.dynamicList

        let prompt = """
        Choose a language to view detailed information on the right.
        This uses the dynamic detail column.
        """

        let detailForItem: (TestItem) -> String = { item in
            let notes = item.additionalNotes.map { "- \($0)" }.joined(separator: "\n")
            
            return """
            \(item.emoji) \(item.name)
            
            \(item.description)
            
            Additional Notes:
            \(notes)
            
            Last Updated:
            \(Date().formatted(date: .numeric, time: .shortened))
            """
        }

        let layout: PickerLayout<TestItem> = .twoColumnDynamic(detailForItem: detailForItem)

        if isMulti {
            let selections = picker.multiSelection(
                prompt: prompt,
                items: items,
                layout: layout,
                newScreen: true
            )

            if selections.isEmpty {
                print("\nNo selections made")
            } else {
                print("\nYou selected \(selections.count) item(s):")
                selections.forEach { item in
                    print(" • \(item.displayName)")
                }
            }
        } else {
            guard let selection = picker.singleSelection(
                prompt: prompt,
                items: items,
                layout: layout,
                newScreen: true
            ) else {
                print("\nNo selection made")
                return
            }

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        }
    }
}

// MARK: - SingleSelection subcommand

extension SwiftPickerDemo {
    struct SingleSelection: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "single",
            abstract: "Test single-selection picker"
        )

        @Flag(name: .shortAndLong, help: "Require a selection and throw if none is made")
        var required = false

        @Flag(name: [.customShort("s"), .long], help: "Use the smaller non-scrolling list")
        var small = false

        @Flag(name: [.customShort("d"), .long], help: "Show static detail column")
        var detail = false

        func run() throws {
            let layout: PickerLayout<TestItem> =
                detail ? .twoColumnStatic(detailText: SwiftPickerDemo.staticDetailText)
                       : .singleColumn

            try SwiftPickerDemo.runSingleDemo(
                layout: layout,
                required: required,
                small: small
            )
        }
    }
}

// MARK: - MultiSelection subcommand

extension SwiftPickerDemo {
    struct MultiSelection: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "multi",
            abstract: "Test multi-selection picker"
        )

        @Flag(name: [.customShort("s"), .long], help: "Use the smaller non-scrolling list")
        var small = false

        @Flag(name: [.customShort("d"), .long], help: "Show static detail column")
        var detail = false

        func run() throws {
            let layout: PickerLayout<TestItem> =
                detail ? .twoColumnStatic(detailText: SwiftPickerDemo.staticDetailText)
                       : .singleColumn

            SwiftPickerDemo.runMultiDemo(
                layout: layout,
                small: small
            )
        }
    }
}

// MARK: - Dynamic two-column detail subcommand

extension SwiftPickerDemo {
    struct DynamicDetail: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "dynamic",
            abstract: "Test dynamic two-column detail picker"
        )

        @Flag(name: [.customShort("s"), .long], help: "Use the smaller list")
        var small = false

        @Flag(name: [.customShort("m"), .long], help: "Use multi-selection mode")
        var multi = false

        func run() throws {
            try SwiftPickerDemo.runDynamicDemo(
                isMulti: multi,
                small: small
            )
        }
    }
}

// MARK: - Choose subcommand (SwiftPicker-driven menu)

extension SwiftPickerDemo {
    struct Choose: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "choose",
            abstract: "Interactively choose layout and selection mode using SwiftPicker"
        )

        func run() throws {
            let picker = SwiftPicker()

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

// MARK: - Tree Navigation (Filesystem Browser)
struct Browse: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "browse",
        abstract: "Browse your filesystem using SwiftPicker tree navigation"
    )

    @Option(
        name: [.customShort("p"), .long],
        help: "Starting path (defaults to your home directory)"
    )
    var path: String?

    @Flag(
        name: [.customShort("H"), .long],
        help: "Show hidden files and folders"
    )
    var showHidden = false

    func run() throws {
        FileSystemNode.showHiddenFiles = showHidden

        let picker = SwiftPicker()

        let startURL: URL
        if let path {
            startURL = URL(fileURLWithPath: path)
        } else {
            startURL = FileManager.default.homeDirectoryForCurrentUser
        }

        let root = FileSystemNode(url: startURL)

        guard let selection = picker.treeNavigation(
            prompt: "Browse folders. Space enters. Backspace goes up.",
            rootItems: [root],
            allowSelectingFolders: true,
            showPromptText: false
        ) else {
            print("\nNo selection made")
            return
        }

        print("\nSelected path:")
        print(selection.url.path)
    }
}
