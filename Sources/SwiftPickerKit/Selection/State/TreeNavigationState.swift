//
//  TreeNavigationState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TreeNavigationState<Item: TreeNodePickerItem> {
    private(set) var levels: [Level]
    private var emptyFolderMessage: String?
    private var emptyFolderIndicator: (level: Int, index: Int)?
    private(set) var activeColumn: ActiveColumn = .current
    private var hideRootLevel = false
    private let rootDisplayName: String?
    
    let prompt: String
    private let showPromptTextValue: Bool
    private let showSelectedItemTextValue: Bool

    init(
        rootItems: [Item],
        rootDisplayName: String? = nil,
        prompt: String,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) {
        self.prompt = prompt
        self.showPromptTextValue = showPromptText
        self.showSelectedItemTextValue = showSelectedItemText
        self.rootDisplayName = rootDisplayName
        self.levels = [.init(items: rootItems, activeIndex: 0)]
    }
}

// MARK: - Methods for Tree Navigation
extension TreeNavigationState {
    var isCurrentColumnActive: Bool {
        return activeColumn == .current
    }

    var isParentColumnActive: Bool {
        return activeColumn == .parent
    }

    var canNavigateLeft: Bool {
        if hideRootLevel && levels.count == 2 {
            return false
        }

        guard let parent = parentLevelInfo else {
            return false
        }

        // When using a named root wrapper, treat the root level as the upper bound.
        if rootDisplayName != nil, parent.index == 0, levels.count <= 2 {
            return false
        }

        return true
    }

    var canNavigateRight: Bool {
        if isParentColumnActive {
            return !currentItems.isEmpty
        }

        guard let selected = currentSelectedItem else {
            return false
        }

        return selected.hasChildren
    }

    var currentItems: [Item] {
        return levels.last?.items ?? []
    }

    var parentLevelInfo: (index: Int, level: Level)? {
        guard levels.count > 1 else {
            return nil
        }

        let candidateIndex = levels.count - 2

        // When hiding the root, suppress showing/navigating the root level.
        if hideRootLevel && candidateIndex == 0 {
            return nil
        }

        return (candidateIndex, levels[candidateIndex])
    }

    var currentLevelInfo: (index: Int, level: Level) {
        guard !levels.isEmpty else {
            return (0, Level(items: [], activeIndex: 0))
        }

        let index = levels.count - 1

        return (index, levels[index])
    }

    func startAtRootContentsIfNeeded() {
        guard rootDisplayName == nil else {
            return
        }

        guard levels.count == 1, let rootLevel = levels.first, rootLevel.items.count == 1 else {
            return
        }

        let root = rootLevel.items[0]
        guard root.hasChildren else {
            return
        }

        let children = root.loadChildren()

        guard !children.isEmpty else {
            emptyFolderIndicator = (level: 0, index: 0)
            emptyFolderMessage = "'\(root.displayName)' is empty"
            levels = [rootLevel, .init(items: [], activeIndex: 0)]
            return
        }

        levels = [rootLevel, .init(items: children, activeIndex: 0)]
        hideRootLevel = true
        activeColumn = .current
        clearEmptyFolderHint()
    }

    func focusParentColumnIfAvailable() {
        guard parentLevelInfo != nil else {
            return
        }

        activeColumn = .parent
    }

    func focusCurrentColumn() {
        activeColumn = .current
    }

    func moveSelectionUp() {
        moveSelection(by: -1)
    }

    func moveSelectionDown() {
        moveSelection(by: 1)
    }

    func updateChildrenForActiveParent(at parentIndex: Int? = nil) {
        let parentDetails: (index: Int, level: Level)?
        if let parentIndex {
            parentDetails = levels.indices.contains(parentIndex) ? (parentIndex, levels[parentIndex]) : nil
        } else {
            parentDetails = parentLevelInfo
        }

        guard let parentInfo = parentDetails else {
            return
        }

        guard parentInfo.level.items.indices.contains(parentInfo.level.activeIndex) else {
            resetCurrentLevel(to: [])
            return
        }

        let selected = parentInfo.level.items[parentInfo.level.activeIndex]
        let children = selected.loadChildren()

        levels = Array(levels.prefix(parentInfo.index + 1))

        guard !children.isEmpty else {
            emptyFolderIndicator = (level: parentInfo.index, index: parentInfo.level.activeIndex)
            emptyFolderMessage = "'\(selected.displayName)' is empty"
            resetCurrentLevel(to: [])
            return
        }

        clearEmptyFolderHint()
        resetCurrentLevel(to: children)
    }

    func clampIndex() {
        clampCurrentLevel()
    }

    func descendIntoChildIfPossible() {
        guard let selected = currentSelectedItem, selected.hasChildren else {
            return
        }

        let depth = currentLevelInfo.index
        let children = selected.loadChildren()

        guard !children.isEmpty else {
            emptyFolderIndicator = (level: depth, index: activeIndex)
            emptyFolderMessage = "'\(selected.displayName)' is empty"
            return
        }

        levels.append(.init(items: children, activeIndex: 0))
        clearEmptyFolderHint()
        activeColumn = .current
    }

    func ascendToParent() {
        guard levels.count > 1 else {
            return
        }

        // If the only parent is the hidden root, do not ascend.
        if hideRootLevel && levels.count == 2 {
            return
        }

        // When using a named root wrapper, do not ascend past the root contents.
        if rootDisplayName != nil && levels.count == 2 {
            return
        }

        levels.removeLast()
        clearEmptyFolderHint()

        if parentLevelInfo != nil {
            activeColumn = .parent
        } else {
            activeColumn = .current
        }
    }

    func breadcrumbPath() -> String {
        let names: [String] = levels.compactMap { level in
            guard level.items.indices.contains(level.activeIndex) else {
                return nil
            }

            return level.items[level.activeIndex].displayName
        }

        if let rootDisplayName {
            return ([rootDisplayName] + names).joined(separator: " ▸ ")
        }

        return names.joined(separator: " ▸ ")
    }

    func isEmptyHint(level levelIndex: Int, index: Int) -> Bool {
        guard let hint = emptyFolderIndicator else {
            return false
        }

        return hint.level == levelIndex && hint.index == index
    }
}

// MARK: - BaseSelectionState Conformance
extension TreeNavigationState: BaseSelectionState {
    var options: [Option<Item>] {
        return currentItems.map { Option(item: $0) }
    }

    var activeIndex: Int {
        get { currentLevel.activeIndex }
        set {
            guard !levels.isEmpty else {
                return
            }

            if currentLevel.activeIndex != newValue {
                clearEmptyFolderHint()
            }

            levels[levels.count - 1].activeIndex = newValue
            clampCurrentLevel()
        }
    }

    var topLineText: String {
        return "SwiftPicker - Tree Navigation"
    }

    var bottomLineText: String {
        return "Arrows: Up/Down move, Right enters, Left switches/ascends, Enter selects"
    }

    var showPromptText: Bool {
        showPromptTextValue
    }

    var showSelectedItemText: Bool {
        showSelectedItemTextValue
    }

    var selectedDetailLines: [String] {
        var lines: [String] = []

        if let item = activeSelectedItem, let metadata = item.metadata {
            if let subtitle = metadata.subtitle {
                lines.append(subtitle.foreColor(240))
            }
            lines.append(contentsOf: metadata.detailLines.map { $0.foreColor(244) })
        }

        if let message = emptyFolderMessage {
            lines.append(message.foreColor(208))
        }

        return lines
    }
}

extension TreeNavigationState: FocusAwareSelectionState {
    var focusedItem: Item? {
        activeSelectedItem
    }
}

// MARK: - Private Methods
private extension TreeNavigationState {
    var currentLevel: Level {
        return levels.last ?? Level(items: [], activeIndex: 0)
    }

    var activeItems: [Item] {
        return isCurrentColumnActive ? currentItems : (parentLevelInfo?.level.items ?? [])
    }

    var activeSelectedItem: Item? {
        guard let index = focusedIndex else {
            return nil
        }

        let items = activeItems
        guard items.indices.contains(index) else {
            return nil
        }
        return items[index]
    }

    var currentSelectedItem: Item? {
        let currentIndex = currentLevel.activeIndex
        guard currentItems.indices.contains(currentIndex) else {
            return nil
        }

        return currentItems[currentIndex]
    }

    var focusedIndex: Int? {
        switch activeColumn {
        case .current:
            return currentLevel.activeIndex
        case .parent:
            return parentLevelInfo?.level.activeIndex
        }
    }

    func clampCurrentLevel() {
        guard !levels.isEmpty else {
            return
        }

        var level = levels[levels.count - 1]

        if level.items.isEmpty {
            level.activeIndex = 0
        } else if level.activeIndex >= level.items.count {
            level.activeIndex = level.items.count - 1
        } else if level.activeIndex < 0 {
            level.activeIndex = 0
        }

        levels[levels.count - 1] = level

        if isParentColumnActive, var parentInfo = parentLevelInfo {
            clampParentLevel(&parentInfo.level)
            levels[parentInfo.index] = parentInfo.level
        }
    }

    func clearEmptyFolderHint() {
        emptyFolderIndicator = nil
        emptyFolderMessage = nil
    }

    func moveSelection(by delta: Int) {
        switch activeColumn {
        case .current:
            activeIndex += delta
            clampCurrentLevel()
        case .parent:
            moveParentSelection(by: delta)
        }
    }

    func moveParentSelection(by delta: Int) {
        guard var parentInfo = parentLevelInfo else {
            return
        }

        parentInfo.level.activeIndex += delta

        clampParentLevel(&parentInfo.level)

        levels[parentInfo.index] = parentInfo.level
        clearEmptyFolderHint()
        updateChildrenForActiveParent(at: parentInfo.index)
    }

    func resetCurrentLevel(to items: [Item]) {
        let newLevel = Level(items: items, activeIndex: 0)

        if levels.isEmpty {
            levels = [newLevel]
        } else {
            // Keep existing ancestor levels intact and add/replace the child level.
            levels.append(newLevel)
        }

        clampCurrentLevel()
    }

    func clampParentLevel(_ level: inout Level) {
        if level.items.isEmpty {
            level.activeIndex = 0
        } else if level.activeIndex >= level.items.count {
            level.activeIndex = level.items.count - 1
        } else if level.activeIndex < 0 {
            level.activeIndex = 0
        }
    }
}

// MARK: - Dependencies
extension TreeNavigationState {
    enum ActiveColumn {
        case current
        case parent
    }

    struct Level {
        var items: [Item]
        var activeIndex: Int
    }
}
