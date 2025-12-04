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


// MARK: - Shared Helpers
extension SwiftPickerDemo {
    static var singlePrompt: String {
        """
        Choose your favorite language to personalize your experience.
        Your choice helps tailor future suggestions, examples, and project
        templates based on what you prefer most.
        """
    }

    static var multiPrompt: String {
        """
        Select any languages you work with regularly.
        Your selections help build a customized toolkit, feature set,
        and workflow recommendations tuned to you.
        """
    }

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

    static func runSingleDemo(layout: PickerLayout<TestItem>, required: Bool, small: Bool) throws {
        let picker = SwiftPicker()
        let items = small ? TestItem.smallList : TestItem.largeList
        let prompt = singlePrompt

        if required {
            let selection = try picker.requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: true, showSelectedItemText: true)

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        } else {
            guard let selection = picker.singleSelection(prompt: prompt, items: items, layout: layout, newScreen: true) else {
                print("\nNo selection made")
                return
            }

            print("\nYou selected: \(selection.displayName)")
            print("Description: \(selection.description)")
        }
    }

    static func runMultiDemo(layout: PickerLayout<TestItem>, small: Bool) {
        let picker = SwiftPicker()
        let items = small ? TestItem.smallList : TestItem.largeList
        let prompt = multiPrompt

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

    static func runDynamicDemo(isMulti: Bool, small: Bool) throws {
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
