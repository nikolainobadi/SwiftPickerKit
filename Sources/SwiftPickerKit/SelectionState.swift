//
//  SelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// A class representing the state of the selection process in `InteractivePicker`.
/// This includes the title, options, active line, and selection mode.
final class SelectionState<Item: DisplayablePickerItem> {
    /// The line position of the top line in the selection list.
    let topLine: Int
    
    /// The title to display at the top of the selection list.
    let title: String
    
    /// A Boolean value indicating whether the selection mode is single selection.
    let isSingleSelection: Bool
    
    /// The line position of the currently active option.
    var activeLine: Int
    
    /// The list of options available for selection.
    var options: [Option<Item>]
    
    /// Initializes a new instance of `SelectionState`.
    /// - Parameters:
    ///   - options: The list of options to select from.
    ///   - topLine: The line position of the top line in the selection list.
    ///   - title: The title to display at the top of the selection list.
    ///   - isSingleSelection: A Boolean value indicating whether the selection mode is single selection.
    init(options: [Option<Item>], topLine: Int, title: String, isSingleSelection: Bool) {
        self.title = title
        self.options = options
        self.topLine = topLine
        self.activeLine = topLine
        self.isSingleSelection = isSingleSelection
    }
}


// MARK: - Helper Methods
extension SelectionState {
    /// An array of the selected options.
    var selectedOptions: [Option<Item>] {
        return options.filter({ $0.isSelected })
    }
    
    /// A tuple representing the range of lines in the selection list.
    var rangeOfLines: (minimum: Int, maximum: Int) {
        return (topLine, topLine + options.count - 1)
    }
    
    /// The text to display at the top line of the selection list.
    var topLineText: String {
        return "InteractivePicker (\(isSingleSelection ? "single" : "multi")-selection)"
    }
    
    /// The text to display at the bottom line of the selection list.
    var bottomLineText: String {
        if isSingleSelection {
            return "Tap 'enter' to select. Type 'q' to quit."
        } else {
            return "Select multiple items with 'spacebar'. Tap 'enter' to finish."
        }
    }
    
    /// Toggles the selection state of the option at the specified line.
    /// - Parameter line: The line position of the option to toggle.
    func toggleSelection(at line: Int) {
        if let activeIndex = options.firstIndex(where: { $0.line == line }) {
            options[activeIndex].isSelected.toggle()
        }
    }
    
    /// Determines whether an option should be shown as selected.
    /// - Parameter option: The option to check.
    /// - Returns: A Boolean value indicating whether the option is selected.
    func showAsSelected(_ option: Option<Item>) -> Bool {
        return isSingleSelection ? option.line == activeLine : option.isSelected
    }
}


// MARK: - Dependencies
/// A structure representing an option in the `SwiftPicker` selection list.
/// Each option contains an item conforming to `DisplayablePickerItem`, its line position in the list, and its selection state.
struct Option<Item: DisplayablePickerItem> {
    /// The item represented by this option.
    let item: Item
    
    /// The line position of this option in the selection list.
    let line: Int
    
    /// A Boolean value indicating whether this option is selected.
    var isSelected: Bool = false
    
    /// The display name of the item, as specified by the `DisplayablePickerItem` protocol.
    var title: String {
        return item.displayName
    }
}
