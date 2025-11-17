//
//  TreeNavigationRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

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
