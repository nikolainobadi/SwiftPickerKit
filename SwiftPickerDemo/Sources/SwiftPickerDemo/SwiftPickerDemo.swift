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
            DynamicDetail.self
        ]
    )
}


// MARK: - SingleSelection
extension SwiftPickerDemo {
    struct SingleSelection: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Test single selection picker")
        
        @Flag(name: .shortAndLong, help: "Require a selection and throw if none is made")
        var required = false

        @Flag(name: [.customShort("s"), .long], help: "Use the smaller non-scrolling list")
        var small = false
        
        @Flag(name: [.customShort("d"), .long], help: "Show static detail column")
        var detail = false
        
        func run() throws {
            let picker = SwiftPicker()
            let items = small ? TestItem.smallList : TestItem.largeList
            
            let prompt = """
            Choose your favorite language to personalize your experience.

            Your choice helps tailor future suggestions, examples,
            and project templates based on what you prefer most.
            """
            
            let detailText = """
            This is my own custom detail text.

            The purpose of this text is to give more information
            to the user as they use my awesome new tool.
            
            This text is static, so it should remain the same
            regardless of which item in the first column is
            currently selected
            """
            
            let layout: PickerLayout<TestItem> = detail ? .twoColumnStatic(detailText: detailText) : .singleColumn
            if required {
                let selection = try picker.requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: true)
//                let selection = try picker.requiredSingleSelection(prompt: prompt, items: items)
//                
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
    }
}


// MARK: - MultiSelection
extension SwiftPickerDemo {
    struct MultiSelection: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Test multi selection picker")

        @Flag(name: [.customShort("s"), .long], help: "Use the smaller non-scrolling list")
        var small = false
        
        func run() throws {
            let picker = SwiftPicker()
            let items = small ? TestItem.smallList : TestItem.largeList
            
            let prompt = """
            Select any languages you work with regularly.

            Your selections help build a customized toolkit,
            feature set, and workflow recommendations tuned to you.
            """
            
            let selections = picker.multiSelection(prompt: prompt, items: items)

            if selections.isEmpty {
                print("\nNo selections made")
            } else {
                print("\nYou selected \(selections.count) item(s):")
                selections.forEach { item in
                    print("  • \(item.displayName)")
                }
            }
        }
    }
}


// MARK: - Dynamic two-column detail test
extension SwiftPickerDemo {
    struct DynamicDetail: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Test dynamic two-column detail picker"
        )

        @Flag(name: [.customShort("s"), .long], help: "Use the smaller list")
        var small = false

        func run() throws {
            let picker = SwiftPicker()

            let items = small ? Array(TestItem.dynamicList.prefix(4))
                              : TestItem.dynamicList

            let prompt = """
            Choose a language to view detailed information on the right.
            This uses the new dynamic detail column.
            """

            // Dynamic detail generator
            let detailForItem: (TestItem) -> String = { item in
                """
                \(item.emoji) \(item.name)

                \(item.description)

                Additional Notes:
                - Selected at: \(Date().formatted(date: .numeric, time: .shortened))
                - This detail text updates instantly as you move.
                - Perfect for file explorers, inspectors, or onboarding flows.
                """
            }

            let layout: PickerLayout<TestItem> = .twoColumnDynamic(detailForItem: detailForItem)

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
