//
//  TwoColumnStaticTextState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TwoColumnStaticTextState<Item: DisplayablePickerItem> {
    private let rawRightText: String
    
    var left: SelectionState<Item>

    init(left: SelectionState<Item>, rightText: String) {
        self.left = left
        self.rawRightText = rightText
    }

    /// Splits and wraps full text for the right column using runtime width.
    func wrappedRightLines(width: Int) -> [String] {
        rawRightText.wrapToWidth(maxWidth: width)
    }
}

extension TwoColumnStaticTextState: BaseSelectionState {
    var activeIndex: Int {
        get { left.activeIndex }
        set { left.activeIndex = newValue }
    }

    var options: [Option<Item>] { left.options }
    var prompt: String { left.prompt }
    var topLineText: String { left.topLineText }
    var bottomLineText: String { left.bottomLineText }

    func toggleSelection(at index: Int) {
        left.toggleSelection(at: index)
    }
}
