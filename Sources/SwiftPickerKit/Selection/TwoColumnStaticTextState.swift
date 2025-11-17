//
//  TwoColumnStaticTextState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TwoColumnStaticTextState<Item: DisplayablePickerItem> {

    var left: SelectionState<Item>
    private let rawRightText: String

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

struct TwoColumnStaticTextSingleBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = TwoColumnStaticTextState<Item>

    func handleSpecialChar(
        char: SpecialChar,
        state: State
    ) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let left = state.left
            let item = left.options[left.activeIndex].item
            return .finishSingle(item)

        case .quit:
            return .finishSingle(nil)

        case .space, .backspace:
            return .continueLoop
        }
    }
}

public enum PickerLayout<Item: DisplayablePickerItem> {
    case singleColumn
    case twoColumnStatic(detailText: String)
    case twoColumnDynamic(detailForItem: (Item) -> String)
}

public extension SwiftPicker {
    func singleSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) -> Item? {
        let outcome: SelectionOutcome<Item> = runSingleSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            newScreen: newScreen
        )

        switch outcome {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    func requiredSingleSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) throws -> Item {
        guard let value = singleSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            newScreen: newScreen
        ) else {
            throw SwiftPickerError.selectionCancelled
        }
        return value
    }
}

internal extension SwiftPicker {
    @discardableResult
    func runSingleSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item>,
        newScreen: Bool
    ) -> SelectionOutcome<Item> {
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }

        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let options = items.map { Option(item: $0) }

        switch layout {
        case .singleColumn:
            let state = SelectionState(
                options: options,
                prompt: prompt,
                isSingleSelection: true
            )

            let behavior = SingleSelectionBehavior<Item>()
            let renderer = SingleColumnRenderer<Item>()

            let handler = SelectionHandler(
                state: state,
                pickerInput: pickerInput,
                behavior: behavior,
                renderer: renderer
            )

            return handler.captureUserInput()

        case .twoColumnStatic(let detailText):
            let base = SelectionState(
                options: options,
                prompt: prompt,
                isSingleSelection: true
            )

            let state = TwoColumnStaticTextState(
                left: base,
                rightText: detailText
            )

            let behavior = TwoColumnStaticTextSingleBehavior<Item>()
            let renderer = TwoColumnStaticTextRenderer<Item>()

            let handler = SelectionHandler(
                state: state,
                pickerInput: pickerInput,
                behavior: behavior,
                renderer: renderer
            )

            return handler.captureUserInput()
        case .twoColumnDynamic(let detailForItem):

            let base = SelectionState(
                options: options,
                prompt: prompt,
                isSingleSelection: true
            )

            let state = TwoColumnDynamicDetailState(
                left: base,
                detailForItem: detailForItem
            )

            let behavior = TwoColumnDynamicDetailSingleBehavior<Item>()
            let renderer = TwoColumnDynamicDetailRenderer<Item>()

            let handler = SelectionHandler(
                state: state,
                pickerInput: pickerInput,
                behavior: behavior,
                renderer: renderer
            )

            return handler.captureUserInput()
        }
    }
}

//
//  String+Wrap.swift
//  SwiftPickerKit
//

extension String {

    /// Wraps a full multiline string into lines that fit a given width,
    /// preserving blank lines and paragraph breaks.
    func wrapToWidth(maxWidth: Int) -> [String] {
        self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .flatMap { line in
                if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    return [""] // preserve blank line
                }
                return line.wrapOneLine(maxWidth: maxWidth)
            }
    }
}

private extension Substring {

    /// Wraps a single line (no newlines) into visual rows.
    func wrapOneLine(maxWidth: Int) -> [String] {
        guard maxWidth > 2 else { return [String(self)] }

        let words = self.split(separator: " ")
        var lines: [String] = []
        var current = ""

        for word in words {
            if current.isEmpty {
                current = String(word)
            } else if current.count + 1 + word.count <= maxWidth {
                current += " \(word)"
            } else {
                lines.append(current)
                current = String(word)
            }
        }

        if !current.isEmpty {
            lines.append(current)
        }

        return lines
    }
}

final class TwoColumnDynamicDetailState<Item: DisplayablePickerItem> {
    var left: SelectionState<Item>
    let detailForItem: (Item) -> String

    init(left: SelectionState<Item>, detailForItem: @escaping (Item) -> String) {
        self.left = left
        self.detailForItem = detailForItem
    }
}

extension TwoColumnDynamicDetailState: BaseSelectionState {
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

struct TwoColumnDynamicDetailSingleBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = TwoColumnDynamicDetailState<Item>

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let item = state.left.options[state.activeIndex].item
            return .finishSingle(item)

        case .quit:
            return .finishSingle(nil)

        case .space, .backspace:
            return .continueLoop
        }
    }
}

struct TwoColumnDynamicDetailRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    typealias State = TwoColumnDynamicDetailState<Item>

    func render(
        items: [Item],
        state: State,
        context: ScrollRenderContext,
        input: PickerInput,
        screenWidth: Int
    ) {
        let leftWidth = max(18, screenWidth / 3)
        let rightWidth = screenWidth - leftWidth - 3

        var row = context.listStartRow

        // LEFT COLUMN (same as static)
        for index in context.startIndex..<context.endIndex {
            let option = state.left.options[index]
            let isActive = index == state.activeIndex

            input.moveTo(row, 0)
            input.moveRight()

            let marker = optionMarker(option: option, isActive: isActive, isSingle: state.left.isSingleSelection)
            input.write(marker)
            input.moveRight()

            let text = PickerTextFormatter.truncate(option.title, maxWidth: leftWidth - 4)
            input.write(isActive ? text.underline : text.foreColor(250))

            row += 1
        }

        // RIGHT COLUMN — dynamic text
        let item = state.left.options[state.activeIndex].item
        let lines = state.detailForItem(item).wrapToWidth(maxWidth: rightWidth)

        row = context.listStartRow
        for line in lines {
            if row >= context.listStartRow + context.visibleRowCount { break }
            input.moveTo(row, leftWidth)
            input.write("│ ".foreColor(240))
            let truncated = PickerTextFormatter.truncate(line, maxWidth: rightWidth)
            input.write(truncated.foreColor(250))
            row += 1
        }
    }

    private func optionMarker(option: Option<Item>, isActive: Bool, isSingle: Bool) -> String {
        if isSingle { return isActive ? "●".lightGreen : "○".foreColor(250) }
        return option.isSelected ? "●".lightGreen : "○".foreColor(250)
    }
}
