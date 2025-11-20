//
//  TestFactory.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

@testable import SwiftPickerKit

enum TestFactory {
    static func makeOptions(count: Int, selectedIndices: Set<Int>) -> [Option<TestItem>] {
        (0..<count).map { index in
            let item = makeItem(name: "Option \(index)")
            let isSelected = selectedIndices.contains(index)
            return Option(item: item, isSelected: isSelected)
        }
    }
    
    static func makeItem(name: String) -> TestItem {
        return .init(name: name)
    }
}
