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
    
    let prompt: String

    init(rootItems: [Item], prompt: String) {
        self.prompt = prompt
        self.levels = [.init(items: rootItems, activeIndex: 0)]
    }
}

// MARK: - BaseSelectionState
extension TreeNavigationState: BaseSelectionState {
    var options: [Option<Item>] {
        currentItems.map { Option(item: $0) }
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

    var topLineText: String { "Tree Navigation" }

    var bottomLineText: String {
        // TODO: - these need to be modified for clarity
        "Arrows: Up/Down highlight, Right enters, Left goes up, Enter selects"
    }

    var selectedDetailLines: [String] {
        var lines: [String] = []

        if let item = currentSelectedItem, let metadata = item.metadata {
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

// MARK: - Helpers
extension TreeNavigationState {
    var currentItems: [Item] {
        return levels.last?.items ?? []
    }

    var parentLevelInfo: (index: Int, level: Level)? {
        guard levels.count > 1 else {
            return nil
        }
        
        let index = levels.count - 2
        
        return (index, levels[index])
    }

    var currentLevelInfo: (index: Int, level: Level) {
        guard !levels.isEmpty else {
            return (0, Level(items: [], activeIndex: 0))
        }
        
        let index = levels.count - 1
        
        return (index, levels[index])
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
    }

    func ascendToParent() {
        guard levels.count > 1 else {
            return
        }
        
        levels.removeLast()
        clearEmptyFolderHint()
    }

    func breadcrumbPath() -> String {
        let names: [String] = levels.compactMap { level in
            guard level.items.indices.contains(level.activeIndex) else {
                return nil
            }
            
            return level.items[level.activeIndex].displayName
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

// MARK: - Private Helpers
private extension TreeNavigationState {
    var currentLevel: Level {
        return levels.last ?? Level(items: [], activeIndex: 0)
    }

    var currentSelectedItem: Item? {
        guard currentItems.indices.contains(activeIndex) else {
            return nil
        }
        
        return currentItems[activeIndex]
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
    }

    func clearEmptyFolderHint() {
        emptyFolderIndicator = nil
        emptyFolderMessage = nil
    }
}


// MARK: - Dependencies
extension TreeNavigationState {
    struct Level {
        var items: [Item]
        var activeIndex: Int
    }
}
