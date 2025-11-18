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
}

public extension CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = true,
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
}
