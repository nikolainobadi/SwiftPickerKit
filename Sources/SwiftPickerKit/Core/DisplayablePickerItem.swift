//
//  DisplayablePickerItem.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// A type that can be shown in a picker; only `displayName` is used for rendering.
///
/// ```swift
/// struct Task: DisplayablePickerItem {
///     let id: String
///     let title: String
///     let priority: Int
///
///     var displayName: String { title }
/// }
/// ```
///
/// `String` conforms, so string arrays can be passed directly as `items`.
public protocol DisplayablePickerItem {
    /// The text shown for this item; keep it short, as long strings may be truncated.
    var displayName: String { get }
}

/// Lets `[String]` be passed directly as picker items.
extension String: DisplayablePickerItem {
    public var displayName: String { self }
}
