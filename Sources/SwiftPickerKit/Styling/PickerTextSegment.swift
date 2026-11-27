/// A run of text in one style, used by `SegmentedPickerItem` to draw a row in several styles.
///
/// Segment text should be plain: don't embed escape codes. A `nil` style uses the row's default
/// look (the item's `displayStyle` when it also conforms to `StyledPickerItem`, otherwise the
/// theme's inactive text color).
public struct PickerTextSegment: Sendable, Equatable {
    public let text: String
    public let style: PickerTextStyle?

    public init(text: String, style: PickerTextStyle?) {
        self.text = text
        self.style = style
    }
}
