struct TwoColumnDynamicDetailRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    let theme: PickerTheme
    let styler: PickerStyler

    init(theme: PickerTheme, styler: PickerStyler) {
        self.theme = theme
        self.styler = styler
    }

    func render(items: [Item], state: TwoColumnDynamicDetailState<Item>, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int) {
        let leftWidth = max(18, screenWidth / 3)
        let rightWidth = screenWidth - leftWidth - 3
        let rowFormatter = OptionRowFormatter(theme: theme, styler: styler)

        var row = context.listStartRow

        for index in context.startIndex..<context.endIndex {
            let option = state.leftState.options[index]
            let isActive = index == state.activeIndex

            input.moveTo(row, 0)
            input.moveRight()
            input.write(rowFormatter.marker(isActive: isActive, isSelected: option.isSelected, isSingleSelection: state.leftState.isSingleSelection))
            input.moveRight()
            input.write(rowFormatter.title(for: option.item, isActive: isActive, maxWidth: leftWidth - 4))

            row += 1
        }

        let item = state.leftState.options[state.activeIndex].item
        let lines = state.detailForItem(item).wrapToWidth(maxWidth: rightWidth)

        row = context.listStartRow
        for line in lines {
            if row >= context.listStartRow + context.visibleRowCount { break }
            input.moveTo(row, leftWidth)
            input.write(styler.styled("│ ", color: theme.divider))
            let truncated = PickerTextFormatter.truncate(line, maxWidth: rightWidth)
            input.write(styler.styled(truncated, color: theme.detailText))
            row += 1
        }
    }
}
