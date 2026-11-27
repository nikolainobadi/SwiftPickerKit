/// The colors `SwiftPicker` uses for its own chrome: markers, pointers, gray text, headers, and arrows.
///
/// Item rows that conform to `StyledPickerItem` use their own style instead of `inactiveText`.
/// A `nil` color draws that element in the terminal's default foreground color.
public struct PickerTheme: Sendable {
    /// Filled `●` marker for the active row (single selection) or selected rows (multi-selection).
    public let marker: PickerColor?

    /// Hollow `○` marker and the text of unstyled, inactive rows.
    public let inactiveText: PickerColor?

    /// Text in the right-hand detail column of two-column layouts.
    public let detailText: PickerColor?

    /// The `│` separator between two columns.
    public let divider: PickerColor?

    /// The `➤` pointer on the active row of the focused tree column.
    public let activePointer: PickerColor?

    /// The `•` pointer on the active row of the unfocused tree column.
    public let inactivePointer: PickerColor?

    /// A tree row whose folder turned out to be empty, and the header message that says so.
    public let emptyHint: PickerColor?

    /// Tree column titles such as `PARENT` and `CURRENT`.
    public let columnHeader: PickerColor?

    /// The tree breadcrumb path above the columns.
    public let breadcrumb: PickerColor?

    /// The `Selected:` line in the header.
    public let selectedHeader: PickerColor?

    /// Scroll arrows, and the `←`/`→` hints beside tree column titles.
    public let scrollArrow: PickerColor?

    /// Placeholder text such as `(empty folder)` in a tree column.
    public let placeholder: PickerColor?

    /// A tree item's `TreeNodeMetadata.subtitle` in the header.
    public let subtitle: PickerColor?

    /// A tree item's `TreeNodeMetadata.detailLines` in the header.
    public let metadataDetail: PickerColor?

    public init(
        marker: PickerColor?,
        inactiveText: PickerColor?,
        detailText: PickerColor?,
        divider: PickerColor?,
        activePointer: PickerColor?,
        inactivePointer: PickerColor?,
        emptyHint: PickerColor?,
        columnHeader: PickerColor?,
        breadcrumb: PickerColor?,
        selectedHeader: PickerColor?,
        scrollArrow: PickerColor?,
        placeholder: PickerColor?,
        subtitle: PickerColor?,
        metadataDetail: PickerColor?
    ) {
        self.marker = marker
        self.inactiveText = inactiveText
        self.detailText = detailText
        self.divider = divider
        self.activePointer = activePointer
        self.inactivePointer = inactivePointer
        self.emptyHint = emptyHint
        self.columnHeader = columnHeader
        self.breadcrumb = breadcrumb
        self.selectedHeader = selectedHeader
        self.scrollArrow = scrollArrow
        self.placeholder = placeholder
        self.subtitle = subtitle
        self.metadataDetail = metadataDetail
    }
}

// MARK: - Standard Theme
public extension PickerTheme {
    /// SwiftPicker's default look: bright green markers and arrows, gray text, and a cyan `Selected:` line.
    static let standard = PickerTheme(
        marker: .brightGreen,
        inactiveText: .palette(250),
        detailText: .palette(250),
        divider: .palette(240),
        activePointer: .brightGreen,
        inactivePointer: .palette(244),
        emptyHint: .palette(208),
        columnHeader: .palette(102),
        breadcrumb: .brightBlue,
        selectedHeader: .palette(51),
        scrollArrow: .brightGreen,
        placeholder: .palette(240),
        subtitle: .palette(240),
        metadataDetail: .palette(244)
    )
}
