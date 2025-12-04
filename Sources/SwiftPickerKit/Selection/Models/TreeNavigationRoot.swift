//
//  TreeNavigationRoot.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 03/02/25.
//

/// Lightweight container that names the conceptual root of a tree and exposes its children.
public struct TreeNavigationRoot<Item: TreeNodePickerItem> {
    public let displayName: String
    public let children: [Item]

    public init(displayName: String, children: [Item]) {
        self.displayName = displayName
        self.children = children
    }
}
