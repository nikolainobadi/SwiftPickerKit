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
    
    public var isSelectable: Bool {
        switch FileSystemNode.selectionType {
        case .onlyFiles:
            return !isDirectory
        case .onlyFolders:
            return isDirectory
        case .filesAndFolders:
            return true
        }
    }
    
    public init(url: URL) {
        self.url = url
        
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
    /// Returns this directory's contents sorted case-insensitively by name, or an empty array
    /// for a file.
    ///
    /// Hidden items are excluded unless `showHiddenFiles` is `true`. When `selectionType` is
    /// `.onlyFolders`, files are excluded too; `.onlyFiles` keeps folders so the files inside
    /// them stay reachable.
    func loadChildren() -> [FileSystemNode] {
        guard isDirectory else { return [] }

        let fm = FileManager.default

        let onlyFolders = FileSystemNode.selectionType == .onlyFolders
        let contents = (try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey])) ?? []
        let filtered = contents.filter { url in
            if !FileSystemNode.showHiddenFiles && url.lastPathComponent.hasPrefix(".") {
                return false
            }

            if onlyFolders {
                return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
            }

            return true
        }

        return filtered.map { FileSystemNode(url: $0) }
            .sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
    }
}

// MARK: - Dependencies
public extension FileSystemNode {
    /// Which nodes a directory browser lists and lets the user select.
    ///
    /// - `onlyFiles`: lists files and folders; only files can be selected.
    /// - `onlyFolders`: lists only folders, and any of them can be selected.
    /// - `filesAndFolders`: lists files and folders; anything can be selected.
    enum SelectionType {
        case onlyFiles, onlyFolders, filesAndFolders
    }
}

// MARK: - Extension Dependencies
public extension FileSystemNode {
    /// Process-wide browsing configuration, set once before browsing begins and never mutated
    /// concurrently; `nonisolated(unsafe)` keeps existing call sites unchanged under Swift 6.
    nonisolated(unsafe) static var showHiddenFiles = false
    nonisolated(unsafe) static var selectionType: SelectionType = .filesAndFolders
}
