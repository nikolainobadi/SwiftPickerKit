/// Draws the up/down scroll arrows in the theme's `scrollArrow` color.
struct ScrollRenderer {
    private let pickerInput: PickerInput
    private let theme: PickerTheme
    private let styler: PickerStyler

    init(pickerInput: PickerInput, theme: PickerTheme, styler: PickerStyler) {
        self.pickerInput = pickerInput
        self.theme = theme
        self.styler = styler
    }
}

// MARK: - Render
extension ScrollRenderer {
    func renderUpArrow(at row: Int) {
        renderArrow("↑", at: row, column: 0)
    }

    func renderDownArrow(at row: Int) {
        renderArrow("↓", at: row, column: 0)
    }

    /// Draws `arrow` at an explicit position; column layouts use it to place arrows per column.
    func renderArrow(_ arrow: String, at row: Int, column: Int) {
        pickerInput.moveTo(row, column)
        pickerInput.write(styler.styled(arrow, color: theme.scrollArrow))
    }
}
