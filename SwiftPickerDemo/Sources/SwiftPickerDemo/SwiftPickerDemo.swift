//
//  SwiftPickerDemo.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import Foundation
import ArgumentParser
import SwiftPickerKit

/// Main entry point for SwiftPickerDemo CLI application.
///
/// This demo showcases all features of SwiftPickerKit through interactive subcommands.
/// Each subcommand demonstrates different picker modes, layouts, and options.
///
/// Usage:
///     swift run SwiftPickerDemo <subcommand> [options]
///
/// Run with `--help` to see all available subcommands and their options.
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


// MARK: - Shared Helpers

extension SwiftPickerDemo {
    /// Prompt text for single-selection demos.
    ///
    /// Multi-line prompts help provide context to users about what they're selecting
    /// and why it matters. This is especially useful for complex CLI tools.
    static var singlePrompt: String {
        """
        Choose your favorite language to personalize your experience.
        Your choice helps tailor future suggestions, examples, and project
        templates based on what you prefer most.
        """
    }

    /// Prompt text for multi-selection demos.
    ///
    /// Note the different framing compared to single-selection: it emphasizes
    /// that multiple selections are expected and explains their purpose.
    static var multiPrompt: String {
        """
        Select any languages you work with regularly.
        Your selections help build a customized toolkit, feature set,
        and workflow recommendations tuned to you.
        """
    }

    /// Static detail text for two-column layout demos.
    ///
    /// This text remains constant regardless of which item is selected in the
    /// left column. Use static detail when you want to show persistent instructions,
    /// help text, or context that applies to all items.
    static var staticDetailText: String {
        """
        This is my own custom detail text.

        The purpose of this text is to give more information
        to the user as they use my awesome new tool.

        This text is static, so it should remain the same
        regardless of which item in the first column is
        currently selected.
        """
    }

    /// Runs a single-selection demo with the specified layout and options.
    ///
    /// Demonstrates both optional and required selection patterns:
    /// - Optional: Returns `nil` if user cancels (q/Ctrl+C)
    /// - Required: Throws `SwiftPickerError.selectionCancelled` if user cancels
    ///
    /// - Parameters:
    ///   - layout: The picker layout to use (single column or two-column static)
    ///   - required: If `true`, uses `requiredSingleSelection` which throws on cancel
    ///   - small: If `true`, uses a smaller non-scrolling list for testing
    static func runSingleDemo(layout: PickerLayout<TestItem>, required: Bool, small: Bool) throws {
        let picker = SwiftPicker()
        let items = small ? TestItem.smallList : TestItem.largeList
        let prompt = singlePrompt

        if required {
            // requiredSingleSelection throws if the user cancels (q or Ctrl+C)
            // Use this pattern when a selection is mandatory for your workflow
            let selection = try picker.requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: true, showSelectedItemText: true)

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        } else {
            // singleSelection returns nil if the user cancels
            // Use this pattern when selection is optional
            guard let selection = picker.singleSelection(prompt: prompt, items: items, layout: layout, newScreen: true) else {
                print("\nNo selection made")
                return
            }

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        }
    }

    /// Runs a multi-selection demo with the specified layout and options.
    ///
    /// Multi-selection allows users to select zero or more items using the space bar.
    /// Always returns an array (empty if user cancels or makes no selections).
    ///
    /// - Parameters:
    ///   - layout: The picker layout to use (single column or two-column static)
    ///   - small: If `true`, uses a smaller non-scrolling list for testing
    static func runMultiDemo(layout: PickerLayout<TestItem>, small: Bool) {
        let picker = SwiftPicker()
        let items = small ? TestItem.smallList : TestItem.largeList
        let prompt = multiPrompt

        // multiSelection always returns an array (empty if cancelled or no selections)
        let selections = picker.multiSelection(prompt: prompt, items: items, layout: layout, newScreen: true)

        if selections.isEmpty {
            print("\nNo selections made")
        } else {
            print("\nYou selected \(selections.count) item(s):")
            selections.forEach { item in
                print(" • \(item.displayName)")
            }
        }
    }

    /// Runs a dynamic two-column detail demo.
    ///
    /// Dynamic detail columns update their content based on the currently selected item.
    /// This is perfect for showing item-specific information like descriptions, metadata,
    /// or preview content.
    ///
    /// Key pattern: Define a closure that maps each item to its detail text. The picker
    /// calls this closure whenever the selection changes to update the detail panel.
    ///
    /// - Parameters:
    ///   - isMulti: If `true`, uses multi-selection mode; otherwise single-selection
    ///   - small: If `true`, uses a smaller list for testing
    static func runDynamicDemo(isMulti: Bool, small: Bool) throws {
        let picker = SwiftPicker()
        let items = small ? Array(TestItem.dynamicList.prefix(4)) : TestItem.dynamicList

        let prompt = """
        Choose a language to view detailed information on the right.
        This uses the dynamic detail column.
        """

        // Define how to generate detail text for each item
        // This closure is called whenever the user navigates to a different item
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

        // Create a dynamic layout by passing the detail closure
        let layout: PickerLayout<TestItem> = .twoColumnDynamic(detailForItem: detailForItem)

        if isMulti {
            let selections = picker.multiSelection(prompt: prompt, items: items, layout: layout, newScreen: true)

            if selections.isEmpty {
                print("\nNo selections made")
            } else {
                print("\nYou selected \(selections.count) item(s):")
                selections.forEach { item in
                    print(" • \(item.displayName)")
                }
            }
        } else {
            guard let selection = picker.singleSelection(prompt: prompt, items: items, layout: layout, newScreen: true) else {
                print("\nNo selection made")
                return
            }

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        }
    }
}
