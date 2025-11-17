//
//  TreeNodePickerItem.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

import Foundation

//
// TreeNavigation.swift
// SwiftPickerKit
//
// Includes: TreeNode, FileSystemNode, lazy-loading, breadcrumbs,
// metadata support, and the core tree navigation implementation.
//


// MARK: - Base Protocol
public protocol TreeNodePickerItem: DisplayablePickerItem {
    var hasChildren: Bool { get }
    func loadChildren() -> [Self]
    var metadata: TreeNodeMetadata? { get }
}


// MARK: - Metadata Container
public struct TreeNodeMetadata {
    public var subtitle: String?         // e.g. "21 files", "Updated yesterday"
    public var detailLines: [String]     // Additional info to show
    public var icon: String?             // Optional override icon

    public init(
        subtitle: String? = nil,
        detailLines: [String] = [],
        icon: String? = nil
    ) {
        self.subtitle = subtitle
        self.detailLines = detailLines
        self.icon = icon
    }
}


// =======================================================================
// MARK: - 1. Generic TreeNode Struct
// =======================================================================

public struct TreeNode<T>: TreeNodePickerItem {
    public let displayName: String
    public let value: T
    public let metadata: TreeNodeMetadata?
    private let childrenLoader: () -> [TreeNode<T>]

    // Lazy caching
    private var cachedChildren: [TreeNode<T>]?
    public var hasChildren: Bool { cachedChildren?.isEmpty == false || _hasChildren }

    private let _hasChildren: Bool

    public init(
        name: String,
        value: T,
        hasChildren: Bool = false,
        metadata: TreeNodeMetadata? = nil,
        loadChildren: @escaping () -> [TreeNode<T>]
    ) {
        self.displayName = name
        self.value = value
        self.metadata = metadata
        self.childrenLoader = loadChildren
        self._hasChildren = hasChildren
    }

    public func loadChildren() -> [TreeNode<T>] {
        if let cached = cachedChildren {
            return cached
        }
        let children = childrenLoader()
        return children
    }
}



// =======================================================================
// MARK: - 2. Filesystem Adapter
// =======================================================================

public struct FileSystemNode: TreeNodePickerItem {
    public let url: URL
    public var metadata: TreeNodeMetadata?

    public var displayName: String { url.lastPathComponent }
    public var hasChildren: Bool { isDirectory }

    private var isDirectory: Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
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

        self.metadata = TreeNodeMetadata(
            subtitle: subtitle,
            detailLines: updated.map { [$0] } ?? [],
            icon: isDirectory ? "📁" : "📄"
        )
    }

    public func loadChildren() -> [FileSystemNode] {
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



// =======================================================================
// MARK: - Breadcrumb utility
// =======================================================================

struct BreadcrumbBuilder {
    static func makePath<Item: TreeNodePickerItem>(
        stack: [[Item]],
        current: [Item]
    ) -> String {
        let names = stack.map { level in
            level.first?.displayName ?? "?"
        } + [current.first?.displayName ?? ""]

        return names
            .filter { !$0.isEmpty }
            .joined(separator: " ▸ ")
    }
}



// =======================================================================
// MARK: - Tree Navigation State
// =======================================================================

final class TreeNavigationState<Item: TreeNodePickerItem>: BaseSelectionState {
    var currentItems: [Item]
    var stack: [[Item]] = []
    var activeIndex: Int = 0
    let prompt: String

    init(rootItems: [Item], prompt: String) {
        self.currentItems = rootItems
        self.prompt = prompt
    }

    // BaseSelectionState
    var options: [Option<Item>] {
        if currentItems.isEmpty { return [] }
        return currentItems.map { Option(item: $0) }
    }

    var topLineText: String { "Tree Navigation" }

    var bottomLineText: String {
        "Arrows: Up/Down highlight, Right enters, Left goes up, Enter selects"
    }

    var selectedDetailLines: [String] {
        guard currentItems.indices.contains(activeIndex) else { return [] }
        let item = currentItems[activeIndex]
        guard let metadata = item.metadata else { return [] }

        var lines: [String] = []
        if let subtitle = metadata.subtitle {
            lines.append(subtitle.foreColor(240))
        }
        lines.append(contentsOf: metadata.detailLines.map { $0.foreColor(244) })
        return lines
    }

    func toggleSelection(at index: Int) {}
}

extension TreeNavigationState {
    func clampIndex() {
        if currentItems.isEmpty {
            activeIndex = 0
        } else if activeIndex >= currentItems.count {
            activeIndex = currentItems.count - 1
        } else if activeIndex < 0 {
            activeIndex = 0
        }
    }
}



// =======================================================================
// MARK: - Behavior
// =======================================================================

final class TreeNavigationBehavior<Item: TreeNodePickerItem>: SelectionBehavior {
    typealias State = TreeNavigationState<Item>
    
    let allowSelectingFolders: Bool
    
    init(allowSelectingFolders: Bool) {
        self.allowSelectingFolders = allowSelectingFolders
    }

    func handleArrow(direction: Direction, state: inout State) {
        switch direction {
        case .up:
            state.activeIndex -= 1
            state.clampIndex()
        case .down:
            state.activeIndex += 1
            state.clampIndex()
        case .right:
            descendIntoChild(state: state)
        case .left:
            ascendToParent(state: state)
        }
    }

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {

        case .space:
            return .continueLoop

        case .backspace:
            return .continueLoop

        case .enter:
            guard !state.currentItems.isEmpty else { return .continueLoop }
            let selected = state.currentItems[state.activeIndex]
            if allowSelectingFolders {
                // Return the selected folder OR file
                return .finishSingle(selected)
            } else {
                // Only allow selecting leaves
                if !selected.hasChildren {
                    return .finishSingle(selected)
                }
            }
            return .continueLoop

        case .quit:
            return .finishSingle(nil)
        }
    }

    private func descendIntoChild(state: State) {
        guard !state.currentItems.isEmpty else { return }
        let selected = state.currentItems[state.activeIndex]
        guard selected.hasChildren else { return }

        let children = selected.loadChildren()
        guard !children.isEmpty else { return }

        state.stack.append(state.currentItems)
        state.currentItems = children
        state.activeIndex = 0
        state.clampIndex()
    }

    private func ascendToParent(state: State) {
        guard !state.currentItems.isEmpty else { return }
        guard let previous = state.stack.popLast() else { return }

        state.currentItems = previous
        state.activeIndex = 0
        state.clampIndex()
    }
}



// =======================================================================
// MARK: - Renderer (Breadcrumbs + Metadata)
// =======================================================================

struct TreeNavigationRenderer<Item: TreeNodePickerItem>: ContentRenderer {
    typealias State = TreeNavigationState<Item>

    func render(
        items: [Item],
        state: State,
        context: ScrollRenderContext,
        input: PickerInput,
        screenWidth: Int
    ) {
        var row = context.listStartRow
        let maxRowExclusive = context.listStartRow + context.visibleRowCount

        // ---------- Breadcrumb line ----------
        let breadcrumb = BreadcrumbBuilder.makePath(
            stack: state.stack,
            current: state.currentItems
        )

        if row < maxRowExclusive {
            input.moveTo(row, 0)
            input.write(breadcrumb.lightBlue)
            row += 1
        }

        if row < maxRowExclusive {
            row += 1 // Blank line after breadcrumb
        }

        // ---------- List of items ----------
        // ---------- Empty folder handling ----------
        if state.currentItems.isEmpty, row < maxRowExclusive {
            input.moveTo(row, 0)
            input.write("  (empty folder)".foreColor(240))
            return
        }
        for index in context.startIndex..<context.endIndex {
            guard state.currentItems.indices.contains(index) else { continue }
            let item = state.currentItems[index]

            if row >= maxRowExclusive { break }

            input.moveTo(row, 0)
            input.moveRight()

            let isActive = index == state.activeIndex
            let prefix = (index == state.activeIndex && !state.currentItems.isEmpty)
                ? "➤".lightGreen
                : " "
            let icon = item.metadata?.icon ?? (item.hasChildren ? "▸" : " ")

            let baseText = "\(prefix) \(icon) \(item.displayName)"
            let truncated = PickerTextFormatter.truncate(baseText, maxWidth: screenWidth - 2)

            if isActive { input.write(truncated.underline) }
            else { input.write(truncated.foreColor(250)) }

            row += 1

            // Metadata now handled by header selected block to keep list compact.
        }
    }
}



// =======================================================================
// MARK: - SwiftPicker Entry Point
// =======================================================================

public extension SwiftPicker {
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true
    ) -> Item? {

        if newScreen { pickerInput.enterAlternativeScreen() }
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let state = TreeNavigationState(rootItems: rootItems, prompt: prompt)
        let behavior = TreeNavigationBehavior<Item>(allowSelectingFolders: allowSelectingFolders)
        let renderer = TreeNavigationRenderer<Item>()

        // Start with first root node opened
        if startInsideFirstRoot, let firstRoot = rootItems.first {
            let children = firstRoot.loadChildren()
            if !children.isEmpty {
                state.stack.append(rootItems)
                state.currentItems = children
                state.activeIndex = 0
            }
        }

        let handler = SelectionHandler(
            state: state,
            pickerInput: pickerInput,
            behavior: behavior,
            renderer: renderer
        )

        let outcome = handler.captureUserInput()
        handler.endSelection()

        switch outcome {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }
}

public extension FileSystemNode {
    static var showHiddenFiles = false
}
