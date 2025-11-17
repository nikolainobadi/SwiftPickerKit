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
// MARK: - Tree Navigation State
// =======================================================================

final class TreeNavigationState<Item: TreeNodePickerItem>: BaseSelectionState {
    struct Level {
        var items: [Item]
        var activeIndex: Int
    }

    private(set) var levels: [Level]
    let prompt: String

    init(rootItems: [Item], prompt: String) {
        self.levels = [Level(items: rootItems, activeIndex: 0)]
        self.prompt = prompt
    }

    // BaseSelectionState
    var options: [Option<Item>] {
        currentItems.map { Option(item: $0) }
    }

    var activeIndex: Int {
        get { levels.last?.activeIndex ?? 0 }
        set {
            guard !levels.isEmpty else { return }
            levels[levels.count - 1].activeIndex = newValue
            clampCurrentLevel()
        }
    }

    var topLineText: String { "Tree Navigation" }

    var bottomLineText: String {
        "Arrows: Up/Down highlight, Right enters, Left goes up, Enter selects"
    }

    var selectedDetailLines: [String] {
        guard let item = currentSelectedItem, let metadata = item.metadata else { return [] }

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
    var currentItems: [Item] {
        levels.last?.items ?? []
    }

    var currentSelectedItem: Item? {
        guard currentItems.indices.contains(activeIndex) else { return nil }
        return currentItems[activeIndex]
    }

    var parentLevel: Level? {
        guard levels.count > 1 else { return nil }
        return levels[levels.count - 2]
    }

    func clampIndex() {
        clampCurrentLevel()
    }

    private func clampCurrentLevel() {
        guard !levels.isEmpty else { return }
        var level = levels[levels.count - 1]

        if level.items.isEmpty {
            level.activeIndex = 0
        } else if level.activeIndex >= level.items.count {
            level.activeIndex = level.items.count - 1
        } else if level.activeIndex < 0 {
            level.activeIndex = 0
        }

        levels[levels.count - 1] = level
    }

    func descendIntoChildIfPossible() {
        guard let selected = currentSelectedItem, selected.hasChildren else { return }
        let children = selected.loadChildren()
        guard !children.isEmpty else { return }

        levels.append(Level(items: children, activeIndex: 0))
    }

    func ascendToParent() {
        guard levels.count > 1 else { return }
        levels.removeLast()
    }

    func breadcrumbPath() -> String {
        let names: [String] = levels.compactMap { level in
            guard level.items.indices.contains(level.activeIndex) else { return nil }
            return level.items[level.activeIndex].displayName
        }

        return names.joined(separator: " ▸ ")
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
            state.descendIntoChildIfPossible()
        case .left:
            state.ascendToParent()
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
}



// =======================================================================
// MARK: - Renderer (Breadcrumbs + Two Columns)
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
        let breadcrumb = state.breadcrumbPath()

        if !breadcrumb.isEmpty, row < maxRowExclusive {
            input.moveTo(row, 0)
            let truncated = PickerTextFormatter.truncate(breadcrumb.lightBlue, maxWidth: screenWidth)
            input.write(truncated)
            row += 1
        }

        if row < maxRowExclusive {
            row += 1 // spacer before columns
        }

        let columnStartRow = row
        let columnSpacing = max(2, screenWidth / 20)
        let columnWidth = max(10, (screenWidth - columnSpacing) / 2)
        let rightColumnStart = min(screenWidth - columnWidth, columnWidth + columnSpacing)

        // Render parent column (left)
        if let parent = state.parentLevel {
            let engine = ScrollEngine(totalItems: parent.items.count, visibleRows: context.visibleRowCount)
            let (start, end) = engine.bounds(activeIndex: parent.activeIndex)
            renderColumn(
                items: parent.items,
                activeIndex: parent.activeIndex,
                startIndex: start,
                endIndex: end,
                title: "Parent",
                isActiveColumn: false,
                startRow: columnStartRow,
                startCol: 0,
                columnWidth: columnWidth,
                maxRowExclusive: maxRowExclusive,
                emptyPlaceholder: "Root level",
                input: input
            )
        } else {
            renderEmptyColumn(
                title: "Parent",
                message: "Root level",
                startRow: columnStartRow,
                startCol: 0,
                columnWidth: columnWidth,
                maxRowExclusive: maxRowExclusive,
                input: input
            )
        }

        // Render current column (right)
        renderColumn(
            items: state.currentItems,
            activeIndex: state.activeIndex,
            startIndex: context.startIndex,
            endIndex: context.endIndex,
            title: "Current",
            isActiveColumn: true,
            startRow: columnStartRow,
            startCol: rightColumnStart,
            columnWidth: columnWidth,
            maxRowExclusive: maxRowExclusive,
            emptyPlaceholder: "(empty folder)",
            input: input
        )
    }
}

private extension TreeNavigationRenderer {
    func renderEmptyColumn(
        title: String,
        message: String,
        startRow: Int,
        startCol: Int,
        columnWidth: Int,
        maxRowExclusive: Int,
        input: PickerInput
    ) {
        guard startRow < maxRowExclusive else { return }
        renderColumnHeader(title: title, startRow: startRow, startCol: startCol, columnWidth: columnWidth, input: input)
        let row = startRow + 1
        guard row < maxRowExclusive else { return }
        input.moveTo(row, startCol + 1)
        let truncated = PickerTextFormatter.truncate(message, maxWidth: max(4, columnWidth - 2))
        input.write(truncated.foreColor(240))
    }

    func renderColumn(
        items: [Item],
        activeIndex: Int,
        startIndex: Int,
        endIndex: Int,
        title: String,
        isActiveColumn: Bool,
        startRow: Int,
        startCol: Int,
        columnWidth: Int,
        maxRowExclusive: Int,
        emptyPlaceholder: String,
        input: PickerInput
    ) {
        guard startRow < maxRowExclusive else { return }
        renderColumnHeader(title: title, startRow: startRow, startCol: startCol, columnWidth: columnWidth, input: input)

        var row = startRow + 1
        let textWidth = max(4, columnWidth - 2)
        let insetCol = startCol + 1

        guard !items.isEmpty else {
            if row < maxRowExclusive {
                input.moveTo(row, insetCol)
                let truncated = PickerTextFormatter.truncate(emptyPlaceholder, maxWidth: textWidth)
                input.write(truncated.foreColor(240))
            }
            return
        }

        let availableRange = startIndex..<min(endIndex, items.count)

        for index in availableRange {
            if row >= maxRowExclusive { break }

            let item = items[index]
            input.moveTo(row, insetCol)

            let pointer: String
            if index == activeIndex {
                pointer = isActiveColumn ? "➤".lightGreen : "•".foreColor(244)
            } else {
                pointer = " "
            }

            let icon = item.metadata?.icon ?? (item.hasChildren ? "▸" : " ")
            let baseText = "\(pointer) \(icon) \(item.displayName)"
            let truncated = PickerTextFormatter.truncate(baseText, maxWidth: textWidth)

            if index == activeIndex && isActiveColumn {
                input.write(truncated.underline)
            } else {
                let color = isActiveColumn ? 250 : 244
                input.write(truncated.foreColor(UInt8(color)))
            }

            row += 1
        }
    }

    func renderColumnHeader(
        title: String,
        startRow: Int,
        startCol: Int,
        columnWidth: Int,
        input: PickerInput
    ) {
        input.moveTo(startRow, startCol)
        let header = PickerTextFormatter.truncate(title.uppercased(), maxWidth: max(4, columnWidth - 1))
        input.write(header.foreColor(102))
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
        if startInsideFirstRoot {
            state.activeIndex = 0
            state.descendIntoChildIfPossible()
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
