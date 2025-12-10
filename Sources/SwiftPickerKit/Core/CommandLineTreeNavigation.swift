//
//  CommandLineTreeNavigation.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

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
    ///   - newScreen: If `true`, uses alternate screen buffer (recommended for clean UX)
    ///   - showPromptText: If `true`, displays the prompt text (can be disabled for cleaner UI)
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: The selected item, or `nil` if the user cancelled
    func treeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, newScreen: Bool, showPromptText: Bool, showSelectedItemText: Bool) -> Item?
}


// MARK: - CommandLineTreeNavigation Convenience
public extension CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, newScreen: Bool = true, showPromptText: Bool = true, showSelectedItemText: Bool = true) -> Item? {
        return treeNavigation(prompt: prompt, root: root, newScreen: newScreen, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText)
    }
    
    func treeNavigation<Item: TreeNodePickerItem>(_ prompt: String, root: TreeNavigationRoot<Item>, newScreen: Bool = true, showPromptText: Bool = true, showSelectedItemText: Bool = true) -> Item? {
        return treeNavigation(prompt: prompt, root: root, newScreen: newScreen, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText)
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, newScreen: Bool, showPromptText: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = treeNavigation(prompt: prompt, root: root, newScreen: newScreen, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText) else {
            throw SwiftPickerError.selectionCancelled
        }
        
        return selection
    }

    func requiredTreeNavigation<Item: TreeNodePickerItem>(_ prompt: String, root: TreeNavigationRoot<Item>, newScreen: Bool = true, showPromptText: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        return try requiredTreeNavigation(prompt: prompt, root: root, newScreen: newScreen, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText)
    }
}
