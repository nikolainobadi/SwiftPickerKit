//
//  FileSystemNode.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

import Foundation

public struct FileSystemNode: TreeNodePickerItem {
    public let url: URL
    public var metadata: TreeNodeMetadata?
    
    public var displayName: String {
        return url.lastPathComponent
    }
    
    public var hasChildren: Bool {
        return isDirectory
    }
    
    private var isDirectory: Bool {
        return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    public init(url: URL) {
        self.url = url
        
        // Metadata support
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = attrs?[.size] as? Int ?? 0
        let modified = attrs?[.modificationDate] as? Date
        
        let subtitle = isDirectory
        ? "Folder"
        : ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        
        let updated = modified.map {
            "Updated: \($0.formatted(date: .numeric, time: .shortened))"
        }
        
        self.metadata = .init(
            subtitle: subtitle,
            detailLines: updated.map { [$0] } ?? [],
            icon: isDirectory ? "📁" : "📄"
        )
    }
}


// MARK: - Helpers
public extension FileSystemNode {
    func loadChildren() -> [FileSystemNode] {
        guard isDirectory else { return [] }

        let fm = FileManager.default

        let contents = (try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []

        let filtered = contents.filter { url in
            if FileSystemNode.showHiddenFiles { return true }

            // Ignore hidden files (dot-prefix)
            return !url.lastPathComponent.hasPrefix(".")
        }

        return filtered.map { FileSystemNode(url: $0) }
            .sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
    }
}


// MARK: - Extension Dependencies
public extension FileSystemNode {
    static var showHiddenFiles = false
}
