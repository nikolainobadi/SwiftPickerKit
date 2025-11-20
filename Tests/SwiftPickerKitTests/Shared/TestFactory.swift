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
            
            return .init(item: item, isSelected: isSelected)
        }
    }
    
    static func makeItem(name: String) -> TestItem {
        return .init(name: name)
    }

    static func makeTreeItems(names: [String], children: [[TreeTestItem]] = [], metadata: [TreeNodeMetadata?] = []) -> [TreeTestItem] {
        names.enumerated().map { index, name in
            let childItems = children.indices.contains(index) ? children[index] : []
            let itemMetadata = metadata.indices.contains(index) ? metadata[index] : nil
            return makeTreeItem(name: name, children: childItems, metadata: itemMetadata)
        }
    }

    static func makeTreeItem(name: String, children: [TreeTestItem] = [], hasChildren: Bool? = nil, metadata: TreeNodeMetadata? = nil) -> TreeTestItem {
        return .init(
            name: name,
            children: children,
            metadata: metadata,
            hasChildrenValue: hasChildren ?? !children.isEmpty
        )
    }

    static func makeTreeMetadata(subtitle: String? = nil, detailLines: [String] = []) -> TreeNodeMetadata {
        return .init(subtitle: subtitle, detailLines: detailLines)
    }
}
