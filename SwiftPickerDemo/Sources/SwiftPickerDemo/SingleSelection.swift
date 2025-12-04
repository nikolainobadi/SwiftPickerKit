//
//  SingleSelection.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    /// Demonstrates single-selection pickers with various layouts and options.
    ///
    /// Single-selection is the most common picker pattern: users navigate with arrow keys
    /// and press Enter to confirm their selection. This subcommand shows both optional
    /// and required selection patterns, as well as single-column and two-column layouts.
    ///
    /// Usage:
    ///     swift run SwiftPickerDemo single [--required] [--small] [--detail]
    ///
    /// Examples:
    ///     swift run SwiftPickerDemo single
    ///     swift run SwiftPickerDemo single --detail
    ///     swift run SwiftPickerDemo single --required --small
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
            // Choose layout based on --detail flag
            // Two-column static shows persistent help text on the right
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
