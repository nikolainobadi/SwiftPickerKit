//
//  Browse.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 12/4/24.
//

import Foundation
import ArgumentParser
import SwiftPickerKit

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
        FileSystemNode.showHiddenFiles = showHidden

        let picker = SwiftPicker()

        let startURL: URL
        if let path {
            startURL = URL(fileURLWithPath: path)
        } else {
            startURL = FileManager.default.homeDirectoryForCurrentUser
        }

        let rootItem = FileSystemNode(url: startURL)
        let rootDisplayName = startURL.lastPathComponent.isEmpty ? startURL.path : startURL.lastPathComponent
        let rootChildren = rootItem.hasChildren ? rootItem.loadChildren() : [rootItem]
        let root = TreeNavigationRoot(displayName: rootDisplayName, children: rootChildren)

        guard let selection = picker.treeNavigation(
            prompt: "Browse folders. Space enters. Backspace goes up.",
            root: root,
            showPromptText: false
        ) else {
            print("\nNo selection made")
            return
        }

        print("\nSelected path:")
        print(selection.url.path)
    }
}
