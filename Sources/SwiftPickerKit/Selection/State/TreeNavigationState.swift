//
//  TreeNavigationState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

/// State for hierarchical tree navigation with breadcrumb tracking and a two-column view.
///
/// Manages a stack of levels (current and parent columns), index clamping, empty-folder
/// indicators/messages, breadcrumb construction (including optional named roots), and
/// optional auto-descend when the root has a single child. Used by
/// `TreeNavigationBehavior` for navigation and `TwoColumnTreeRenderer` for display.
final class TreeNavigationState<Item: TreeNodePickerItem> {
    /// Stack of navigation levels, from root to current depth.
    /// Each level contains items at that depth and the active index within those items.
    private(set) var levels: [Level]

    /// Message displayed when navigating into an empty folder.
    private var emptyFolderMessage: String?

    /// Tracks which parent item led to an empty folder (level index + item index).
    private var emptyFolderIndicator: (level: Int, index: Int)?

    /// Which column currently has focus (.current = right, .parent = left).
    private(set) var activeColumn: ActiveColumn = .current

    /// Whether the root level is hidden (auto-descend into single root item).
    private var hideRootLevel = false

    /// Optional display name for root level shown in breadcrumb path.
    private let rootDisplayName: String?

    let prompt: String
    private let showPromptTextValue: Bool
    private let showSelectedItemTextValue: Bool

    /// Creates a tree navigation state starting at the given root items.
    ///
    /// - Parameters:
    ///   - rootItems: Top-level items to display (e.g., root directory nodes)
    ///   - rootDisplayName: Optional name for root shown in breadcrumb (e.g., "Home")
    ///   - prompt: Main instruction text
    ///   - showPromptText: Whether to show prompt in header (default: true)
    ///   - showSelectedItemText: Whether to show selected item in header (default: true)
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
    /// Whether the current column (right) has focus.
    var isCurrentColumnActive: Bool {
        return activeColumn == .current
    }

    /// Whether the parent column (left) has focus.
    var isParentColumnActive: Bool {
        return activeColumn == .parent
    }

    /// Whether left arrow navigation is allowed (ascend or switch to parent column).
    ///
    /// Left navigation is blocked when:
    /// - At root level with no parent
    /// - Using hidden root and only one level above it exists
    /// - Using named root wrapper and at the root contents level
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

    /// Whether right arrow navigation is allowed (descend into child).
    ///
    /// Right navigation is blocked when:
    /// - Current column focused and selected item has no children
    /// - Parent column focused and current level is empty
    var canNavigateRight: Bool {
        if isParentColumnActive {
            return !currentItems.isEmpty
        }

        guard let selected = currentSelectedItem else {
            return false
        }

        return selected.hasChildren
    }

    /// Items at the current (deepest) level in the navigation stack.
    var currentItems: [Item] {
        return levels.last?.items ?? []
    }

    /// Information about the parent level (one level up from current).
    ///
    /// Returns `nil` if:
    /// - Only one level exists (at root)
    /// - Root level is hidden and parent would be the hidden root
    ///
    /// - Returns: Tuple of (level index, level data) or `nil` if no accessible parent
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

    /// Information about the current level (deepest level in the stack).
    ///
    /// Returns empty level if stack is empty (should never happen in normal usage).
    ///
    /// - Returns: Tuple of (level index, level data)
    var currentLevelInfo: (index: Int, level: Level) {
        guard !levels.isEmpty else {
            return (0, Level(items: [], activeIndex: 0))
        }

        let index = levels.count - 1

        return (index, levels[index])
    }

    /// Auto-descends into root item if it's the only item with children.
    ///
    /// Hides the redundant single-item root level and starts at its children. Breadcrumbs
    /// still include the root's display name when present.
    ///
    /// ## Empty Root Handling
    ///
    /// If the root item has no children, sets an empty folder indicator and message.
    ///
    /// ## When Not Applied
    ///
    /// - Using a named root wrapper (`rootDisplayName != nil`)
    /// - Root level has multiple items
    /// - Root item has no children
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

    /// Switches focus to parent column if a parent level exists.
    ///
    /// Used by `TreeNavigationBehavior` when left arrow is pressed from current column.
    func focusParentColumnIfAvailable() {
        guard parentLevelInfo != nil else {
            return
        }

        activeColumn = .parent
    }

    /// Switches focus back to current column.
    ///
    /// Used by `TreeNavigationBehavior` when right arrow is pressed from parent column.
    func focusCurrentColumn() {
        activeColumn = .current
    }

    /// Moves selection up by one item in the active column.
    func moveSelectionUp() {
        moveSelection(by: -1)
    }

    /// Moves selection down by one item in the active column.
    func moveSelectionDown() {
        moveSelection(by: 1)
    }

    /// Updates the current level's children based on the parent's active selection.
    ///
    /// Called when:
    /// - Parent column selection changes (user navigates up/down in parent)
    /// - Explicitly refreshing children for a specific parent level
    ///
    /// ## Behavior
    ///
    /// 1. Gets parent level info (uses `parentLevelInfo` by default or explicit `parentIndex`)
    /// 2. Loads children from parent's active item using `loadChildren()`
    /// 3. Truncates level stack to parent level
    /// 4. Adds new child level or sets empty folder indicator
    ///
    /// ## Empty/Invalid Handling
    ///
    /// If the parent's active index is invalid, or if the active item has no children, the
    /// current level is reset to an empty array (with indicator/message only when children
    /// are missing).
    ///
    /// - Parameter parentIndex: Optional explicit parent level index (defaults to current parent)
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

    /// Clamps the current level's active index to valid range.
    ///
    /// Called after navigation to ensure `activeIndex` doesn't exceed item count.
    func clampIndex() {
        clampCurrentLevel()
    }

    /// Descends into the selected item's children, adding a new navigation level.
    ///
    /// This is the core **right arrow navigation** action. When the current selection
    /// has children, this method:
    /// 1. Loads children using `loadChildren()`
    /// 2. Appends a new level to the stack with those children
    /// 3. Focuses the current column
    ///
    /// ## Empty Folder Handling
    ///
    /// If the selected item has `hasChildren = true` but `loadChildren()` returns empty,
    /// sets an empty folder indicator and displays a warning message instead of descending.
    ///
    /// ## When Blocked
    ///
    /// Does nothing if:
    /// - No item is selected
    /// - Selected item has `hasChildren = false`
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

    /// Ascends to the parent level, removing the current level from the stack.
    ///
    /// This is the core **left arrow navigation** action when parent column is focused.
    /// When ascending:
    /// 1. Removes the current (deepest) level from the stack
    /// 2. Focuses parent column if a parent still exists
    /// 3. Clears any empty folder indicators
    ///
    /// ## When Blocked
    ///
    /// Does nothing if:
    /// - Only one level exists (at root)
    /// - Root level is hidden and only one level above it exists
    /// - Using named root wrapper and at the root contents level
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

    /// Generates a breadcrumb path string showing the navigation hierarchy.
    ///
    /// Returns a string like: `"Users ▸ Documents ▸ Projects ▸ SwiftPickerKit"`
    ///
    /// ## Path Construction
    ///
    /// - Iterates through all levels in the stack
    /// - Takes the `displayName` of the active item at each level
    /// - Joins names with the `▸` separator
    /// - Prepends `rootDisplayName` if provided
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Without named root
    /// state.breadcrumbPath()  // "Users ▸ you ▸ Projects"
    ///
    /// // With named root
    /// let state = TreeNavigationState(rootItems: [node], rootDisplayName: "Home", ...)
    /// state.breadcrumbPath()  // "Home ▸ Projects ▸ SwiftPickerKit"
    /// ```
    ///
    /// Displayed in the header by `PickerHeaderRenderer` to show current location.
    ///
    /// - Returns: Breadcrumb path string with ▸ separators
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

    /// Checks if a specific item is marked with an empty folder indicator.
    ///
    /// Used by `TwoColumnTreeRenderer` to show visual hints (e.g., orange highlight)
    /// for items that were found to have no children.
    ///
    /// - Parameters:
    ///   - levelIndex: The level index of the item
    ///   - index: The item index within that level
    /// - Returns: `true` if this item is marked as having an empty folder
    func isEmptyHint(level levelIndex: Int, index: Int) -> Bool {
        guard let hint = emptyFolderIndicator else {
            return false
        }

        return hint.level == levelIndex && hint.index == index
    }
}

// MARK: - BaseSelectionState Conformance
extension TreeNavigationState: BaseSelectionState {
    /// Returns options from the current (deepest) level wrapped in `Option` objects.
    ///
    /// Unlike simple pickers that show all options, tree navigation only shows
    /// the current level's items. The renderer shows parent items separately.
    var options: [Option<Item>] {
        return currentItems.map { Option(item: $0) }
    }

    /// Active index within the current level.
    ///
    /// Setting this updates the last level's `activeIndex` and clamps it to valid range.
    /// Also clears empty folder hints when the selection changes.
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

    /// Detail lines shown below the selected item in the header.
    ///
    /// Combines:
    /// - Item metadata (subtitle and detail lines) in gray colors
    /// - Empty folder message (if any) in orange
    ///
    /// This provides contextual information about the currently focused item.
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

/// Conforms to `FocusAwareSelectionState` to provide focused item for header display.
///
/// Tree navigation needs this because the "focused" item may be in the parent column
/// (left), not the current column (right). The header shows details for whichever
/// column has focus.
extension TreeNavigationState: FocusAwareSelectionState {
    /// The currently focused item (may be from parent or current column).
    ///
    /// Returns:
    /// - Item from current column if `.current` is active
    /// - Item from parent column if `.parent` is active
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
    /// Tracks which column currently has focus in the two-column tree display.
    enum ActiveColumn {
        /// Current (right) column has focus - arrow keys navigate current level
        case current

        /// Parent (left) column has focus - arrow keys navigate parent level
        case parent
    }

    /// Represents one level in the tree navigation hierarchy.
    struct Level {
        /// Items at this level in the tree hierarchy
        var items: [Item]

        /// Index of the currently active/selected item at this level
        var activeIndex: Int
    }
}
