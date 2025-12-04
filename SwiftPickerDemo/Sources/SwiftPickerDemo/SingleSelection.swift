//
//  SingleSelection.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

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
