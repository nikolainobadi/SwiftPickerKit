//
//  CommandLineTreeNavigation.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Public interface for hierarchical tree navigation pickers.
public protocol CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool
    ) -> Item?
    
    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool
    ) throws -> Item
}

public extension CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen
        )
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true
    ) throws -> Item {
        return try requiredTreeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen
        )
    }
}
