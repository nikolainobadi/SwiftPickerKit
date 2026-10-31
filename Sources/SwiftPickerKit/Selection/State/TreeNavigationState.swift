//
//  TreeNavigationState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

/// State for two-column tree navigation: a stack of levels from root to the current depth,
/// with the parent level shown in the left column and the current level in the right.
final class TreeNavigationState<Item: TreeNodePickerItem> {
    private(set) var levels: [Level]

    private var emptyFolderMessage: String?

    /// Level and index of the item last found to have no children; drives the empty-folder highlight.
    private var emptyFolderIndicator: (level: Int, index: Int)?

    private(set) var activeColumn: ActiveColumn = .current

    /// Set when a lone root was auto-descended; its level stays in `levels` and the breadcrumb but is never shown as a column or navigated to.
    private var hideRootLevel = false

    /// Prefixes the breadcrumb and makes the root contents the upper navigation bound.
    private let rootDisplayName: String?

    let prompt: String
    private let showPromptTextValue: Bool
    private let showSelectedItemTextValue: Bool

    /// - Parameter rootDisplayName: Breadcrumb prefix (e.g. "Home"); also disables auto-descend and stops ascending at the root contents.
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

    /// Whether left arrow can ascend or focus the parent column.
    ///
    /// False at the root, at the contents of a hidden root, and at the root contents under a named root.
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

    /// Whether right arrow can act: descend from the current column, or refocus it from the parent column when it isn't empty.
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

    /// The level above the current one, or `nil` at the root or when that level is the hidden root.
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

    /// The deepest level; an empty level if the stack is somehow empty.
    var currentLevelInfo: (index: Int, level: Level) {
        guard !levels.isEmpty else {
            return (0, Level(items: [], activeIndex: 0))
        }

        let index = levels.count - 1

        return (index, levels[index])
    }

    /// Starts at a lone root's children and hides the redundant root level.
    ///
    /// Skipped with a named root, multiple roots, or a root without children. If the root's
    /// children load empty, the root stays visible and is marked as an empty folder.
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

    /// Reloads the child level from a parent level's active item.
    ///
    /// The child level becomes empty when the parent's active index is out of range or the item
    /// has no children; only the latter marks it as an empty folder.
    ///
    /// - Parameter parentIndex: Level to treat as the parent; `nil` uses `parentLevelInfo`.
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

    /// Pushes the selected item's children as a new level and focuses the current column.
    ///
    /// If `hasChildren` is true but the children load empty, marks the item as an empty folder
    /// instead of descending.
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

    /// Pops the current level, keeping parent-column focus while a visible parent remains.
    ///
    /// Does nothing at the root, at the contents of a hidden root, or at the root contents under a named root.
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

    /// The active item's name at every level (hidden root included), joined with ` ▸ ` and
    /// prefixed by `rootDisplayName` when set, e.g. `"Home ▸ Projects ▸ SwiftPickerKit"`.
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

    /// Whether the item at `levelIndex`/`index` is marked as an empty folder.
    func isEmptyHint(level levelIndex: Int, index: Int) -> Bool {
        guard let hint = emptyFolderIndicator else {
            return false
        }

        return hint.level == levelIndex && hint.index == index
    }
}

// MARK: - BaseSelectionState Conformance
extension TreeNavigationState: BaseSelectionState {
    /// Only the current level; the renderer draws the parent column separately.
    var options: [Option<Item>] {
        return currentItems.map { Option(item: $0) }
    }

    /// Active index within the current level; setting clamps it and clears the empty-folder hint if it changed.
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

    /// The focused item's metadata in gray, followed by any empty-folder message in orange.
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

/// Focus can sit in the parent column, so the header asks for the focused item rather than using `activeIndex`.
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
        /// Right column
        case current

        /// Left column
        case parent
    }

    struct Level {
        var items: [Item]

        var activeIndex: Int
    }
}
