//
//  DynamicDetail.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
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
            try SwiftPickerDemo.runDynamicDemo(
                isMulti: multi,
                small: small
            )
        }
    }
}
