//
//  DisplayablePickerItem.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Core protocol that all picker items must conform to.
///
/// `DisplayablePickerItem` is the fundamental requirement for any type you want to display
/// in a SwiftPicker. It requires a single property: `displayName`, which provides the text
/// shown to users in the picker interface.
///
/// ## Usage
///
/// Any type can conform to `DisplayablePickerItem`:
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
/// For simple String arrays, you can use them directly since String conforms automatically:
///
/// ```swift
/// let items = ["Option 1", "Option 2", "Option 3"]
/// picker.singleSelection(prompt: "Choose", items: items)
/// ```
///
/// ## Design Philosophy
///
/// This protocol is intentionally minimal. It only requires what's absolutely necessary
/// to display items in a picker. Your types can have any additional properties they need;
/// only `displayName` is used for rendering in the picker interface.
public protocol DisplayablePickerItem {
    /// The text displayed for this item in the picker interface.
    ///
    /// This should be a concise, human-readable string that uniquely identifies the item
    /// to users. Avoid very long strings as they may be truncated in the UI.
    var displayName: String { get }
}

/// String automatically conforms to DisplayablePickerItem for convenience.
///
/// This allows you to use String arrays directly with SwiftPicker without
/// creating custom types:
///
/// ```swift
/// let languages = ["Swift", "Python", "JavaScript"]
/// picker.singleSelection(prompt: "Choose a language", items: languages)
/// ```
extension String: DisplayablePickerItem {
    public var displayName: String { self }
}
