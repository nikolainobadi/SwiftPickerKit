//
//  File.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 12/10/25.
//

import Foundation

public extension CommandLineTreeNavigation {
    func browseDirectories(prompt: String, startURL: URL, showPromptText: Bool = true, showSelectedItemText: Bool = true) -> FileSystemNode? {
        let rootNode = FileSystemNode(url: startURL)
        let root = TreeNavigationRoot(displayName: startURL.lastPathComponent, children: rootNode.loadChildren())
        
        return treeNavigation(prompt, root: root, newScreen: true, showPromptText: showPromptText, showSelectedItemText: showSelectedItemText)
    }
}
