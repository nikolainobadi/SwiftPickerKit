//
//  MultiSelection.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

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
