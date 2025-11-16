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
        
        func run() throws {
            let picker = InteractivePicker()
            let items = TestItem.sampleItems
            let title = "Choose your favorite"
            
            if required {
                let selection = try picker.requiredSingleSelection(title: title, items: items)
                
                print("\nYou selected: \(selection.displayName)")
                print("Description: \(selection.description)")
            } else {
                guard let selection = picker.singleSelection(title: "Choose your favorite", items: items) else {
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

        func run() throws {
            let picker = InteractivePicker()
            let items = TestItem.sampleItems
            let selections = picker.multiSelection(title: "Choose multiple items", items: items)

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
