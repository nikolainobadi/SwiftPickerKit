//
//  Browse.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import Foundation
import ArgumentParser
import SwiftPickerKit

/// Demonstrates tree navigation for hierarchical data structures.
///
/// Tree navigation is perfect for browsing hierarchical structures like:
/// - File systems
/// - Organization charts
/// - Nested categories or taxonomies
/// - Menu systems
/// - Any parent-child data structure
///
/// Users navigate with:
/// - Up/Down arrows: Move between items at the current level
/// - Right arrow or Space: Enter a folder/expand a node
/// - Left arrow or Backspace: Go up to parent level
/// - Enter: Select the current item (if selectable)
/// - q: Cancel and exit
///
/// This demo uses `FileSystemNode`, SwiftPickerKit's built-in implementation
/// of `TreeNodePickerItem` for browsing the filesystem.
///
/// Usage:
///     swift run SwiftPickerDemo browse [--path <path>] [--show-hidden]
///
/// Examples:
///     swift run SwiftPickerDemo browse
///     swift run SwiftPickerDemo browse --path ~/Projects
///     swift run SwiftPickerDemo browse --show-hidden
struct Browse: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "browse",
        abstract: "Browse your filesystem using SwiftPicker tree navigation"
    )

    @Option(name: [.customShort("p"), .long], help: "Starting path (defaults to your home directory)")
    var path: String?

    @Flag(name: [.customShort("H"), .long], help: "Show hidden files and folders")
    var showHidden = false

    func run() throws {
        // Configure FileSystemNode to show/hide hidden files
        FileSystemNode.showHiddenFiles = showHidden

        let picker = SwiftPicker()

        // Determine starting directory
        let startURL: URL
        if let path {
            startURL = URL(fileURLWithPath: path)
        } else {
            startURL = FileManager.default.homeDirectoryForCurrentUser
        }

        // Create the root node
        // FileSystemNode conforms to TreeNodePickerItem and handles loading children
        let rootItem = FileSystemNode(url: startURL)
        let rootDisplayName = startURL.lastPathComponent.isEmpty ? startURL.path : startURL.lastPathComponent
        let rootChildren = rootItem.hasChildren ? rootItem.loadChildren() : [rootItem]

        // Wrap in TreeNavigationRoot (required by the tree navigation API)
        let root = TreeNavigationRoot(displayName: rootDisplayName, children: rootChildren)

        // Launch tree navigation
        guard let selection = picker.treeNavigation(
            prompt: "Browse folders. Space enters. Backspace goes up.",
            root: root,
            showPromptText: false
        ) else {
            print("\nNo selection made")
            return
        }

        // Display the selected path
        print("\nSelected path:")
        print(selection.url.path)
    }
}
