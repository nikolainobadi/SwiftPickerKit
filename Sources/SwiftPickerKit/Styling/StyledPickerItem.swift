/// A picker item that chooses how its `displayName` is drawn.
///
/// Conform when some items should stand out, such as failed jobs in red or stale branches dimmed.
/// Items that don't conform keep the theme's default look.
///
/// ```swift
/// struct Job: StyledPickerItem {
///     let name: String
///     let failed: Bool
///
///     var displayName: String { name }
///     var displayStyle: PickerTextStyle? { failed ? .failure : nil }
/// }
/// ```
///
/// Pickers truncate the plain `displayName` before styling it, so don't embed escape codes in
/// `displayName` itself. The active row keeps this style and adds an underline; rows in the
/// inactive tree-navigation column are also dimmed.
public protocol StyledPickerItem: DisplayablePickerItem {
    /// The style for this item's row, or `nil` for the theme's default.
    var displayStyle: PickerTextStyle? { get }
}

// MARK: - Internal Helpers
extension DisplayablePickerItem {
    /// The item's `displayStyle` when it conforms to `StyledPickerItem`, otherwise `nil`.
    var resolvedDisplayStyle: PickerTextStyle? {
        return (self as? any StyledPickerItem)?.displayStyle
    }
}
