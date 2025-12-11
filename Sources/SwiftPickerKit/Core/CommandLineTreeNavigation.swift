//
//  CommandLineTreeNavigation.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Foundation

/// Public interface for hierarchical tree navigation pickers.
///
/// Tree navigation is designed for browsing hierarchical data structures like file systems,
/// organization charts, category hierarchies, or any parent-child relationship.
///
/// ## Navigation Controls
///
/// Users interact with tree pickers using:
/// - **Up/Down arrows** — Move between items at the current level
/// - **Right arrow or Space** — Enter a folder/expand a node (descend)
/// - **Left arrow or Backspace** — Go up to parent level (ascend)
/// - **Enter** — Select the current item (if `isSelectable` is `true`)
/// - **'q' or Ctrl+C** — Cancel and exit
///
/// ## TreeNodePickerItem Protocol
///
/// Items must conform to `TreeNodePickerItem`, which extends `DisplayablePickerItem` with:
/// - `hasChildren: Bool` — Whether this node has child nodes
/// - `isSelectable: Bool` — Whether this node can be selected (e.g., files yes, folders no)
/// - `loadChildren() -> [Self]` — Lazy loading of child nodes
/// - `metadata: TreeNodeMetadata?` — Optional subtitle, icon, and detail lines
///
/// ## Built-in Implementation
///
/// SwiftPickerKit provides `FileSystemNode` for browsing the filesystem:
///
/// ```swift
/// let rootNode = FileSystemNode(url: URL(fileURLWithPath: "/Users/you/Projects"))
/// let root = TreeNavigationRoot(items: [rootNode])
///
/// if let selected = picker.treeNavigation(prompt: "Browse files", root: root) {
///     print("Selected: \(selected.url.path)")
/// }
/// ```
public protocol CommandLineTreeNavigation {
    /// Displays an interactive tree navigation picker.
    ///
    /// The picker shows a breadcrumb path at the top and displays the current level's items.
    /// Users can navigate up and down the hierarchy, and select items marked as selectable.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - root: The root container wrapping initial tree items
    ///   - showPromptText: If `true`, displays the prompt text (can be disabled for cleaner UI)
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: The selected item, or `nil` if the user cancelled
    func treeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>,showPromptText: Bool, showSelectedItemText: Bool) -> Item?
    
    /// Presents a directory browser rooted at `startURL`.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - startURL: Directory to use as the initial navigation root
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    ///   - selectionType: Controls whether files, folders, or both can be selected
    /// - Returns: The selected file system node, or `nil` if the user cancelled
    func browseDirectories(prompt: String, startURL: URL, showPromptText: Bool, showSelectedItemText: Bool, selectionType: FileSystemNode.SelectionType) -> FileSystemNode?
}


// MARK: - CommandLineTreeNavigation Convenience
public extension CommandLineTreeNavigation {
    /// Displays a tree navigation picker and throws if the user cancels.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - root: The root container wrapping initial tree items
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Throws: `SwiftPickerError.selectionCancelled` when the user exits without a selection
    /// - Returns: The selected item
    func requiredTreeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, showPromptText: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = treeNavigation(prompt: prompt, root: root, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText) else {
            throw SwiftPickerError.selectionCancelled
        }
        
        return selection
    }
    
    /// Browses the file system starting at `startURL`, applying optional UI toggles and selection filtering.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - startURL: Directory to use as the initial navigation root
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    ///   - selectionType: Controls whether files, folders, or both can be selected
    /// - Returns: The selected file system node, or `nil` if the user cancelled
    func browseDirectories(prompt: String, startURL: URL, showPromptText: Bool = true, showSelectedItemText: Bool = true, selectionType: FileSystemNode.SelectionType = .filesAndFolders) -> FileSystemNode? {
        let rootNode = FileSystemNode(url: startURL)
        let root = TreeNavigationRoot(displayName: startURL.lastPathComponent, children: rootNode.loadChildren())
        
        FileSystemNode.selectionType = selectionType
        
        return treeNavigation(prompt: prompt, root: root, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText)
    }
}
