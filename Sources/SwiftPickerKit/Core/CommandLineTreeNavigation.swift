//
//  CommandLineTreeNavigation.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

import Foundation

/// Pickers that browse a hierarchy of `TreeNodePickerItem`s, such as a file system.
///
/// Up/Down move within a level, Right or Space descends, Left or Backspace ascends, Enter
/// selects the current item if it `isSelectable`, and `q` cancels. Children are loaded lazily
/// via `loadChildren()`. `FileSystemNode` is the built-in file system implementation:
///
/// ```swift
/// let rootNode = FileSystemNode(url: URL(fileURLWithPath: "/Users/you/Projects"))
/// let root = TreeNavigationRoot(displayName: "Projects", children: [rootNode])
///
/// if let selected = picker.treeNavigation(prompt: "Browse files", root: root) {
///     print("Selected: \(selected.url.path)")
/// }
/// ```
public protocol CommandLineTreeNavigation {
    /// Displays a tree navigation picker with a breadcrumb path above the current level's items.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - root: The root container wrapping initial tree items
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    /// - Returns: The selected item, or `nil` if cancelled
    func treeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>,showPromptText: Bool, showSelectedItemText: Bool) -> Item?
    
    /// Presents a directory browser rooted at `startURL`.
    ///
    /// - Parameters:
    ///   - prompt: Text displayed at the top of the picker
    ///   - startURL: Directory to use as the initial navigation root
    ///   - showPromptText: If `true`, displays the prompt text
    ///   - showSelectedItemText: If `true`, shows selected item text in the header
    ///   - selectionType: Controls whether files, folders, or both can be selected
    /// - Returns: The selected node, or `nil` if cancelled
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
    /// - Throws: `PickerInterruptedError` if a `SwiftPicker` prompt is ended by Ctrl+C or SIGTERM
    ///   while the host keeps running; otherwise `SwiftPickerError.selectionCancelled` if cancelled
    /// - Returns: The selected item
    func requiredTreeNavigation<Item: TreeNodePickerItem>(prompt: String, root: TreeNavigationRoot<Item>, showPromptText: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        guard let selection = treeNavigation(prompt: prompt, root: root, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText) else {
            if let interruption = PickerInterruptedError.interruption(for: self) {
                throw interruption
            }

            throw SwiftPickerError.selectionCancelled
        }
        
        return selection
    }
    
    /// Convenience overload of `browseDirectories` with default parameter values; builds the root
    /// from `startURL`'s contents and passes it to `treeNavigation`.
    ///
    /// - Note: Reads the directory listing and sets the process-global
    ///   `FileSystemNode.selectionType` before delegating.
    func browseDirectories(prompt: String, startURL: URL, showPromptText: Bool = true, showSelectedItemText: Bool = true, selectionType: FileSystemNode.SelectionType = .filesAndFolders) -> FileSystemNode? {
        let rootNode = FileSystemNode(url: startURL)
        let root = TreeNavigationRoot(displayName: startURL.lastPathComponent, children: rootNode.loadChildren())
        
        FileSystemNode.selectionType = selectionType
        
        return treeNavigation(prompt: prompt, root: root, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText)
    }
}
