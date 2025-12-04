//
//  DynamicDetail.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    /// Demonstrates dynamic two-column detail panels.
    ///
    /// Dynamic detail columns update their content based on the currently selected item.
    /// As users navigate through the list, the detail panel on the right updates to show
    /// information about the active item. This is ideal for:
    /// - Showing item descriptions or metadata
    /// - Displaying preview content
    /// - Providing context-sensitive help
    /// - Showing detailed properties or attributes
    ///
    /// Unlike static detail (which shows the same text for all items), dynamic detail
    /// calls a closure for each item to generate its specific content.
    ///
    /// Usage:
    ///     swift run SwiftPickerDemo dynamic [--small] [--multi]
    ///
    /// Examples:
    ///     swift run SwiftPickerDemo dynamic
    ///     swift run SwiftPickerDemo dynamic --multi
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
            // Dynamic detail works with both single and multi-selection
            try SwiftPickerDemo.runDynamicDemo(
                isMulti: multi,
                small: small
            )
        }
    }
}
