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
        rootDisplayName: String?,
        newScreen: Bool,
        showPromptText: Bool,
        showSelectedItemText: Bool
    ) -> Item?
}


// MARK: - CommandLineTreeNavigation Convenience
public extension CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            rootDisplayName: nil,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }
    
    func treeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            rootDisplayName: nil,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }

    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        root: TreeNavigationRoot<Item>,
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            rootItems: root.children,
            rootDisplayName: root.displayName,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }

    func treeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        root: TreeNavigationRoot<Item>,
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            root: root,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        newScreen: Bool,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) throws -> Item {
        guard let selection = treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            rootDisplayName: nil,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        ) else {
            throw SwiftPickerError.selectionCancelled
        }
        return selection
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        rootItems: [Item],
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) throws -> Item {
        return try requiredTreeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        root: TreeNavigationRoot<Item>,
        newScreen: Bool,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) throws -> Item {
        guard let selection = treeNavigation(
            prompt: prompt,
            root: root,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        ) else {
            throw SwiftPickerError.selectionCancelled
        }
        return selection
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        root: TreeNavigationRoot<Item>,
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) throws -> Item {
        return try requiredTreeNavigation(
            prompt: prompt,
            root: root,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }
}
