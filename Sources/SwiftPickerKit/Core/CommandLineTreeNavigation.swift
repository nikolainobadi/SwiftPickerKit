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
        newScreen: Bool,
        showPromptText: Bool
    ) -> Item?
}


// MARK: - CommandLineTreeNavigation Convenience
public extension CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true,
        showPromptText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen,
            showPromptText: showPromptText
        )
    }
    
    func treeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true,
        showPromptText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen,
            showPromptText: showPromptText
        )
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool,
        showPromptText: Bool = true
    ) throws -> Item {
        guard let selection = treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen,
            showPromptText: showPromptText
        ) else {
            throw SwiftPickerError.selectionCancelled
        }
        return selection
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true,
        showPromptText: Bool = true
    ) throws -> Item {
        return try requiredTreeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen,
            showPromptText: showPromptText
        )
    }
}
