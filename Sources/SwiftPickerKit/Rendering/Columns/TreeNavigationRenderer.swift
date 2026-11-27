struct TreeNavigationRenderer<Item: TreeNodePickerItem>: ContentRenderer {
    let theme: PickerTheme
    let styler: PickerStyler

    init(theme: PickerTheme, styler: PickerStyler) {
        self.theme = theme
        self.styler = styler
    }

    func renderScrollIndicators(showUp: Bool, showDown: Bool, state: TreeNavigationState<Item>, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int, headerHeight: Int, totalRows: Int) {
        let footerRenderer = PickerFooterRenderer(pickerInput: input)
        let scrollRenderer = ScrollRenderer(pickerInput: input, theme: theme, styler: styler)
        let footerStartRow = totalRows - footerRenderer.height()
        let arrowRow = headerHeight - 1

        let breadcrumbRows = state.breadcrumbPath().isEmpty ? 0 : 1
        let spacerRow = 1
        let columnHeaderRows = 1
        let actualVisibleRows = context.visibleRowCount - breadcrumbRows - spacerRow - columnHeaderRows

        let hasParent = state.parentLevelInfo != nil
        let columnSpacing = hasParent ? max(2, screenWidth / 20) : 0
        let columnWidth = hasParent ? max(10, (screenWidth - columnSpacing) / 2) : max(10, screenWidth)
        let rightColumnStart = hasParent ? min(screenWidth - columnWidth, columnWidth + columnSpacing) : 0

        if let parentInfo = state.parentLevelInfo {
            let parent = parentInfo.level
            let engine = ScrollEngine(totalItems: parent.items.count, visibleRows: actualVisibleRows)
            let (start, end) = engine.bounds(activeIndex: parent.activeIndex)

            if engine.showScrollUp(start: start) {
                scrollRenderer.renderArrow("↑", at: arrowRow, column: 0)
            }

            if engine.showScrollDown(end: end) {
                scrollRenderer.renderArrow("↓", at: footerStartRow, column: 0)
            }
        }

        let currentInfo = state.currentLevelInfo
        let currentEngine = ScrollEngine(totalItems: currentInfo.level.items.count, visibleRows: actualVisibleRows)
        let (currentStart, currentEnd) = currentEngine.bounds(activeIndex: currentInfo.level.activeIndex)

        if currentEngine.showScrollUp(start: currentStart) {
            scrollRenderer.renderArrow("↑", at: arrowRow, column: rightColumnStart)
        }

        if currentEngine.showScrollDown(end: currentEnd) {
            scrollRenderer.renderArrow("↓", at: footerStartRow, column: rightColumnStart)
        }
    }

    func render(items: [Item], state: TreeNavigationState<Item>, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int) {
        var row = context.listStartRow
        let maxRowExclusive = context.listStartRow + context.visibleRowCount
        let breadcrumb = state.breadcrumbPath()

        if !breadcrumb.isEmpty, row < maxRowExclusive {
            input.moveTo(row, 0)
            let truncated = PickerTextFormatter.truncate(breadcrumb, maxWidth: screenWidth)
            input.write(styler.styled(truncated, color: theme.breadcrumb))
            row += 1
        }

        if row < maxRowExclusive {
            row += 1
        }

        let columnStartRow = row
        let rowsConsumedByBreadcrumb = row - context.listStartRow
        let columnHeaderRows = 1
        let actualVisibleRows = context.visibleRowCount - rowsConsumedByBreadcrumb - columnHeaderRows
        let hasParent = state.parentLevelInfo != nil
        let columnSpacing = hasParent ? max(2, screenWidth / 20) : 0
        let columnWidth = hasParent ? max(10, (screenWidth - columnSpacing) / 2) : max(10, screenWidth)
        let rightColumnStart = hasParent ? min(screenWidth - columnWidth, columnWidth + columnSpacing) : 0

        if let parentInfo = state.parentLevelInfo {
            let parent = parentInfo.level
            let engine = ScrollEngine(totalItems: parent.items.count, visibleRows: actualVisibleRows)
            let (start, end) = engine.bounds(activeIndex: parent.activeIndex)
            renderColumn(
                items: parent.items,
                activeIndex: parent.activeIndex,
                startIndex: start,
                endIndex: end,
                title: "Parent",
                isActiveColumn: state.isParentColumnActive,
                showLeadingArrow: state.isParentColumnActive && state.canNavigateLeft,
                showTrailingArrow: state.isParentColumnActive && state.canNavigateRight,
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
        let currentTitle = state.isCurrentColumnActive ? "Current" : "Children"
        let currentEngine = ScrollEngine(totalItems: currentInfo.level.items.count, visibleRows: actualVisibleRows)
        let (currentStart, currentEnd) = currentEngine.bounds(activeIndex: currentInfo.level.activeIndex)
        renderColumn(
            items: currentInfo.level.items,
            activeIndex: currentInfo.level.activeIndex,
            startIndex: currentStart,
            endIndex: currentEnd,
            title: currentTitle,
            isActiveColumn: state.isCurrentColumnActive,
            showLeadingArrow: state.isCurrentColumnActive && state.canNavigateLeft,
            showTrailingArrow: state.isCurrentColumnActive && state.canNavigateRight,
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
    func renderColumn(
        items: [Item],
        activeIndex: Int,
        startIndex: Int,
        endIndex: Int,
        title: String,
        isActiveColumn: Bool,
        showLeadingArrow: Bool,
        showTrailingArrow: Bool,
        levelIndex: Int,
        startRow: Int,
        startCol: Int,
        columnWidth: Int,
        maxRowExclusive: Int,
        emptyPlaceholder: String,
        input: PickerInput,
        state: State
    ) {
        guard startRow < maxRowExclusive else {
            return
        }
        
        renderColumnHeader(title: title, startRow: startRow, startCol: startCol, columnWidth: columnWidth, showLeadingArrow: showLeadingArrow, showTrailingArrow: showTrailingArrow, input: input)

        var row = startRow + 1
        let textWidth = max(4, columnWidth - 2)
        let insetCol = startCol + 1

        guard !items.isEmpty else {
            if row < maxRowExclusive {
                input.moveTo(row, insetCol)
                let truncated = PickerTextFormatter.truncate(emptyPlaceholder, maxWidth: textWidth)
                input.write(styler.styled(truncated, color: theme.placeholder))
            }
            return
        }

        let availableRange = startIndex..<min(endIndex, items.count)

        for index in availableRange {
            if row >= maxRowExclusive {
                break
            }

            let item = items[index]
            input.moveTo(row, insetCol)
            let emptyHint = state.isEmptyHint(level: levelIndex, index: index)

            let isActiveRow = index == activeIndex
            input.write(makePointer(isActiveRow: isActiveRow, isActiveColumn: isActiveColumn))
            input.write(" ")

            let segments = makeRowSegments(item: item, isEmptyHint: emptyHint)
            let truncated = PickerTextFormatter.truncate(segments, maxWidth: textWidth - 2)

            for segment in truncated {
                let style = makeRowStyle(item: item, segmentStyle: segment.style, isEmptyHint: emptyHint, isActiveRow: isActiveRow, isActiveColumn: isActiveColumn)
                input.write(styler.styled(segment.text, as: style))
            }

            row += 1
        }
    }

    func renderColumnHeader(title: String, startRow: Int, startCol: Int, columnWidth: Int, showLeadingArrow: Bool, showTrailingArrow: Bool, input: PickerInput) {
        input.moveTo(startRow, startCol)
        let clearLine = String(repeating: " ", count: max(0, columnWidth))
        input.write(clearLine)
        input.moveTo(startRow, startCol)

        let plainTitle = title.uppercased()
        var plainParts: [String] = []
        if showLeadingArrow {
            plainParts.append("←")
        }
        plainParts.append(plainTitle)
        if showTrailingArrow {
            plainParts.append("→")
        }

        let spacedPlain = plainParts.joined(separator: " ")
        let useSpaced = spacedPlain.count <= columnWidth

        var coloredParts: [String] = []
        if showLeadingArrow {
            coloredParts.append(styler.styled("←", color: theme.scrollArrow))
        }
        coloredParts.append(styler.styled(plainTitle, color: theme.columnHeader))
        if showTrailingArrow {
            coloredParts.append(styler.styled("→", color: theme.scrollArrow))
        }
        let spacedColored = coloredParts.joined(separator: " ")
        let compactColored = coloredParts.joined()
        let headerText = useSpaced ? spacedColored : compactColored

        input.write(headerText)
    }

    /// `➤` on the active row of the focused column, `•` on the active row of the other column,
    /// otherwise a space.
    func makePointer(isActiveRow: Bool, isActiveColumn: Bool) -> String {
        guard isActiveRow else {
            return " "
        }

        return isActiveColumn ? styler.styled("➤", color: theme.activePointer) : styler.styled("•", color: theme.inactivePointer)
    }

    /// The row's plain text pieces: the icon, then the item's `displaySegments` (or `displayName`),
    /// then `(empty)` for an empty folder. A row without segments stays a single piece.
    func makeRowSegments(item: Item, isEmptyHint: Bool) -> [PickerTextSegment] {
        let icon = item.metadata?.icon ?? (item.hasChildren ? "▸" : " ")
        let emptySuffix = isEmptyHint ? " (empty)" : ""

        guard let itemSegments = item.resolvedDisplaySegments else {
            return [PickerTextSegment(text: "\(icon) \(item.displayName)\(emptySuffix)", style: nil)]
        }

        return [PickerTextSegment(text: "\(icon) ", style: nil)] + itemSegments + [PickerTextSegment(text: emptySuffix, style: nil)]
    }

    /// The segment's style, then the item's style, then the theme's inactive text; replaced by the
    /// empty hint color when the folder is empty, underlined on the focused active row, and dimmed
    /// in the unfocused column.
    func makeRowStyle(item: Item, segmentStyle: PickerTextStyle?, isEmptyHint: Bool, isActiveRow: Bool, isActiveColumn: Bool) -> PickerTextStyle {
        var style = isEmptyHint ? .colored(theme.emptyHint) : (segmentStyle ?? item.resolvedDisplayStyle ?? .colored(theme.inactiveText))

        if isActiveRow && isActiveColumn {
            style = style.underlined
        }

        if !isActiveColumn {
            style = style.dimmed
        }

        return style
    }
}
