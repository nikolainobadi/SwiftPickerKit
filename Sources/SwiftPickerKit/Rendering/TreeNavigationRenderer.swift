//
//  TreeNavigationRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TreeNavigationRenderer<Item: TreeNodePickerItem>: ContentRenderer {
    func render(items: [Item], state: TreeNavigationState<Item>, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int) {
        var row = context.listStartRow
        let maxRowExclusive = context.listStartRow + context.visibleRowCount
        let breadcrumb = state.breadcrumbPath()

        if !breadcrumb.isEmpty, row < maxRowExclusive {
            input.moveTo(row, 0)
            let truncated = PickerTextFormatter.truncate(breadcrumb.lightBlue, maxWidth: screenWidth)
            input.write(truncated)
            row += 1
        }

        if row < maxRowExclusive {
            row += 1
        }

        let columnStartRow = row
        let hasParent = state.parentLevelInfo != nil
        let columnSpacing = hasParent ? max(2, screenWidth / 20) : 0
        let columnWidth = hasParent ? max(10, (screenWidth - columnSpacing) / 2) : max(10, screenWidth)
        let rightColumnStart = hasParent ? min(screenWidth - columnWidth, columnWidth + columnSpacing) : 0

        if let parentInfo = state.parentLevelInfo {
            let parent = parentInfo.level
            let engine = ScrollEngine(totalItems: parent.items.count, visibleRows: context.visibleRowCount)
            let (start, end) = engine.bounds(activeIndex: parent.activeIndex)
            renderColumn(
                items: parent.items,
                activeIndex: parent.activeIndex,
                startIndex: start,
                endIndex: end,
                title: "Parent",
                isActiveColumn: false,
                levelIndex: parentInfo.index,
                startRow: columnStartRow,
                startCol: 0,
                columnWidth: columnWidth,
                maxRowExclusive: maxRowExclusive,
                emptyPlaceholder: "Root level",
                input: input,
                state: state
            )
        }

        let currentInfo = state.currentLevelInfo
        renderColumn(
            items: currentInfo.level.items,
            activeIndex: currentInfo.level.activeIndex,
            startIndex: context.startIndex,
            endIndex: context.endIndex,
            title: "Current",
            isActiveColumn: true,
            levelIndex: currentInfo.index,
            startRow: columnStartRow,
            startCol: rightColumnStart,
            columnWidth: columnWidth,
            maxRowExclusive: maxRowExclusive,
            emptyPlaceholder: "(empty folder)",
            input: input,
            state: state
        )
    }
}


// MARK: - Private Methods
private extension TreeNavigationRenderer {
    func renderColumn(items: [Item], activeIndex: Int, startIndex: Int, endIndex: Int, title: String, isActiveColumn: Bool, levelIndex: Int, startRow: Int, startCol: Int, columnWidth: Int, maxRowExclusive: Int, emptyPlaceholder: String, input: PickerInput, state: State) {
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
            let emptyHint = state.isEmptyHint(level: levelIndex, index: index)

            let pointer: String
            if index == activeIndex {
                pointer = isActiveColumn ? "➤".lightGreen : "•".foreColor(244)
            } else {
                pointer = " "
            }

            let icon = item.metadata?.icon ?? (item.hasChildren ? "▸" : " ")
            var baseText = "\(pointer) \(icon) \(item.displayName)"
            if emptyHint {
                baseText += " (empty)"
            }
            let truncated = PickerTextFormatter.truncate(baseText, maxWidth: textWidth)

            let defaultColor: UInt8 = isActiveColumn ? 250 : 244
            let color: UInt8 = emptyHint ? 208 : defaultColor
            var styled = truncated.foreColor(color)
            if index == activeIndex && isActiveColumn {
                styled = styled.underline
            }
            input.write(styled)

            row += 1
        }
    }

    func renderColumnHeader(title: String, startRow: Int, startCol: Int, columnWidth: Int, input: PickerInput) {
        input.moveTo(startRow, startCol)
        let header = PickerTextFormatter.truncate(title.uppercased(), maxWidth: max(4, columnWidth - 1))
        input.write(header.foreColor(102))
    }
}
