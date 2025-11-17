//
//  TreeNavigationState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

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
