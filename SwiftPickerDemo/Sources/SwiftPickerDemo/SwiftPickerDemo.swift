//
//  SwiftPickerDemo.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ArgumentParser
import SwiftPickerKit

@main
struct SwiftPickerDemo: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Test tool for SwiftPickerKit",
        subcommands: [
            SingleSelection.self,
            MultiSelection.self
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
        
        func run() throws {
            let picker = InteractivePicker()
            let items = small ? TestItem.smallList : TestItem.largeList
            
            let prompt = """
            Choose your favorite language to personalize your experience.

            Your choice helps tailor future suggestions, examples,
            and project templates based on what you prefer most.
            """
            
            if required {
                let selection = try picker.requiredSingleSelection(prompt: prompt, items: items)
                
                print("\nYou selected: \(selection.displayName)")
                print("Description: \(selection.description)")
            } else {
                guard let selection = picker.singleSelection(prompt: prompt, items: items) else {
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
            let picker = InteractivePicker()
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


