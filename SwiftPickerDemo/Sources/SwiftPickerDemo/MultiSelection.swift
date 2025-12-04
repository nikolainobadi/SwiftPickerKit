//
//  MultiSelection.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    /// Demonstrates multi-selection pickers (checkbox-style).
    ///
    /// Multi-selection allows users to select zero or more items using the space bar
    /// to toggle selections. Users navigate with arrow keys and press Enter to confirm.
    /// Perfect for scenarios where multiple items need to be selected (features to enable,
    /// files to process, tags to apply, etc.).
    ///
    /// Key differences from single-selection:
    /// - Space bar toggles selection (adds checkmark)
    /// - Enter confirms all selected items
    /// - Always returns an array (empty if cancelled)
    ///
    /// Usage:
    ///     swift run SwiftPickerDemo multi [--small] [--detail]
    ///
    /// Examples:
    ///     swift run SwiftPickerDemo multi
    ///     swift run SwiftPickerDemo multi --detail
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
            // Same layout options as single-selection
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
