struct SingleColumnRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    let theme: PickerTheme
    let styler: PickerStyler

    init(theme: PickerTheme, styler: PickerStyler) {
        self.theme = theme
        self.styler = styler
    }

    func render(items: [Item], state: SelectionState<Item>, context: ScrollRenderContext, input: PickerInput, screenWidth: Int) {
        let rowFormatter = OptionRowFormatter(theme: theme, styler: styler)
        var row = context.listStartRow

        for index in context.startIndex..<context.endIndex {
            let option = state.options[index]
            let isActive = (index == state.activeIndex)

            input.moveTo(row, 0)
            input.moveRight()
            input.write(rowFormatter.marker(isActive: isActive, isSelected: option.isSelected, isSingleSelection: state.isSingleSelection))
            input.moveRight()
            input.write(rowFormatter.title(for: option.item, isActive: isActive, maxWidth: screenWidth - 4))

            row += 1
        }
    }
}
