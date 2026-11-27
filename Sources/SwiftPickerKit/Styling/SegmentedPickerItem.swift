/// A picker item whose row is drawn from several differently styled segments.
///
/// Conform when parts of a row need their own colors, such as a status column where `failed` is
/// red and `not fixed` is yellow. Pickers draw the segments in place of `displayName`, which is
/// still used for the header's `Selected:` line and the tree breadcrumb, so derive it from the
/// segments to keep the two in sync:
///
/// ```swift
/// struct SkillRow: SegmentedPickerItem {
///     let name: String
///     let failed: Bool
///
///     var displayName: String { displaySegments.map(\.text).joined() }
///     var displaySegments: [PickerTextSegment] {
///         [
///             PickerTextSegment(text: name.padding(toLength: 18, withPad: " ", startingAt: 0), style: nil),
///             PickerTextSegment(text: failed ? "failed" : "passed", style: failed ? .failure : .success)
///         ]
///     }
/// }
/// ```
///
/// Pickers truncate across segments by visible width before styling them; a cut ends with `…` in
/// the style of the segment that was cut. The active row underlines every segment, and rows in the
/// inactive tree-navigation column dim every segment. When an item also conforms to
/// `StyledPickerItem`, its `displayStyle` is used for segments whose style is `nil`.
public protocol SegmentedPickerItem: DisplayablePickerItem {
    /// The styled pieces of this item's row, drawn in order.
    var displaySegments: [PickerTextSegment] { get }
}

// MARK: - Internal Helpers
extension DisplayablePickerItem {
    /// The item's `displaySegments` when it conforms to `SegmentedPickerItem`, otherwise `nil`.
    var resolvedDisplaySegments: [PickerTextSegment]? {
        return (self as? any SegmentedPickerItem)?.displaySegments
    }
}
