struct TwoColumnStaticTextRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    let theme: PickerTheme
    let styler: PickerStyler

    init(theme: PickerTheme, styler: PickerStyler) {
        self.theme = theme
        self.styler = styler
    }

    func render(items: [Item], state: TwoColumnStaticTextState<Item>, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int) {
        let leftWidth = max(18, screenWidth / 3)
        let rightWidth = screenWidth - leftWidth - 3
        let rowFormatter = OptionRowFormatter(theme: theme, styler: styler)

        var row = context.listStartRow

        for index in context.startIndex..<context.endIndex {
            let option = state.leftState.options[index]
            let isActive = index == state.leftState.activeIndex

            input.moveTo(row, 0)
            input.moveRight()
            input.write(rowFormatter.marker(isActive: isActive, isSelected: option.isSelected, isSingleSelection: state.leftState.isSingleSelection))
            input.moveRight()
            input.write(rowFormatter.title(for: option.item, isActive: isActive, maxWidth: leftWidth - 4))

            row += 1
        }

        renderRightColumnBlock(
            fullTextLines: state.wrappedRightLines(width: rightWidth),
            context: context,
            leftWidth: leftWidth,
            rightWidth: rightWidth,
            input: input
        )
    }
}

// MARK: - Private Methods
private extension TwoColumnStaticTextRenderer {
    func renderRightColumnBlock(fullTextLines: [String], context: ScrollRenderContext, leftWidth: Int, rightWidth: Int, input: PickerInput) {
        var row = context.listStartRow

        for line in fullTextLines {
            if row >= context.listStartRow + context.visibleRowCount {
                break
            }

            input.moveTo(row, leftWidth)
            input.write(styler.styled("│", color: theme.divider))
            input.moveRight()

            let truncated = PickerTextFormatter.truncate(line, maxWidth: rightWidth - 2)
            input.write(styler.styled(truncated, color: theme.detailText))

            row += 1
        }
    }
}
