/// Builds the marker and title text for list rows, shared by the single- and two-column renderers.
struct OptionRowFormatter {
    let theme: PickerTheme
    let styler: PickerStyler

    init(theme: PickerTheme, styler: PickerStyler) {
        self.theme = theme
        self.styler = styler
    }
}

// MARK: - Row Pieces
extension OptionRowFormatter {
    /// `●` for the active row in single selection or a selected row in multi-selection, otherwise `○`.
    func marker(isActive: Bool, isSelected: Bool, isSingleSelection: Bool) -> String {
        let isFilled = isSingleSelection ? isActive : isSelected

        return isFilled ? styler.styled("●", color: theme.marker) : styler.styled("○", color: theme.inactiveText)
    }

    /// The item's `displaySegments` (or `displayName`), truncated to `maxWidth` and then styled.
    ///
    /// Inactive rows use each segment's style, then the item's `displayStyle`, then
    /// `theme.inactiveText`. The active row keeps those styles, using the default foreground
    /// instead of `theme.inactiveText`, and underlines every segment.
    func title<Item: DisplayablePickerItem>(for item: Item, isActive: Bool, maxWidth: Int) -> String {
        let itemStyle = item.resolvedDisplayStyle

        guard let segments = item.resolvedDisplaySegments else {
            let truncated = PickerTextFormatter.truncate(item.displayName, maxWidth: maxWidth)
            return styler.styled(truncated, as: makeStyle(itemStyle, isActive: isActive))
        }

        return PickerTextFormatter.truncate(segments, maxWidth: maxWidth)
            .map { styler.styled($0.text, as: makeStyle($0.style ?? itemStyle, isActive: isActive)) }
            .joined()
    }
}

// MARK: - Private Methods
private extension OptionRowFormatter {
    func makeStyle(_ style: PickerTextStyle?, isActive: Bool) -> PickerTextStyle {
        if isActive {
            return (style ?? .colored(nil)).underlined
        }

        return style ?? .colored(theme.inactiveText)
    }
}
