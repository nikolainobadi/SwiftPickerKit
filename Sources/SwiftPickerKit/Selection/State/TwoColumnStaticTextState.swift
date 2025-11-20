//
//  TwoColumnStaticTextState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TwoColumnStaticTextState<Item: DisplayablePickerItem> {
    private let rawRightText: String

    var leftState: SelectionState<Item>

    init(leftState: SelectionState<Item>, rightText: String) {
        self.leftState = leftState
        self.rawRightText = rightText
    }

    /// Splits and wraps full text for the right column using runtime width.
    func wrappedRightLines(width: Int) -> [String] {
        rawRightText.wrapToWidth(maxWidth: width)
    }
}

extension TwoColumnStaticTextState: BaseSelectionState {
    var activeIndex: Int {
        get { leftState.activeIndex }
        set { leftState.activeIndex = newValue }
    }

    var options: [Option<Item>] { leftState.options }
    var prompt: String { leftState.prompt }
    var topLineText: String { leftState.topLineText }
    var bottomLineText: String { leftState.bottomLineText }

    func toggleSelection(at index: Int) {
        leftState.toggleSelection(at: index)
    }
}
