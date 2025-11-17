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

extension SwiftPicker {
    public func singleSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) -> Item? {
        switch runSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            isSingle: true,
            newScreen: newScreen
        ) {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    public func requiredSingleSelection<Item: DisplayablePickerItem>(
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
    
    public func multiSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) -> [Item] {
        switch runSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            isSingle: false,
            newScreen: newScreen
        ) {
        case .finishMulti(let items):
            return items
        default:
            return []
        }
    }
}

internal extension SwiftPicker {
    @discardableResult
    func runSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item>,
        isSingle: Bool,
        newScreen: Bool
    ) -> SelectionOutcome<Item> {

        if newScreen {
            pickerInput.enterAlternativeScreen()
        }

        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let options = items.map { Option(item: $0) }

        // Base state for single-column or left-column of two-column
        let baseState = SelectionState(
            options: options,
            prompt: prompt,
            isSingleSelection: isSingle
        )

        switch layout {

        // -----------------------------------------------------
        // 1. SINGLE COLUMN
        // -----------------------------------------------------
        case .singleColumn:

            if isSingle {
                let behavior = SingleSelectionBehavior<Item>()
                let renderer = SingleColumnRenderer<Item>()

                let handler = SelectionHandler(
                    state: baseState,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()

            } else {
                let behavior = MultiSelectionBehavior<Item>()
                let renderer = SingleColumnRenderer<Item>()

                let handler = SelectionHandler(
                    state: baseState,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            }

        // -----------------------------------------------------
        // 2. TWO COLUMN STATIC
        // -----------------------------------------------------
        case .twoColumnStatic(let detailText):

            let state = TwoColumnStaticTextState(
                left: baseState,
                rightText: detailText
            )
            let renderer = TwoColumnStaticTextRenderer<Item>()

            if isSingle {
                let behavior = TwoColumnStaticTextSingleBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()

            } else {
                let behavior = TwoColumnStaticTextMultiBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            }

        // -----------------------------------------------------
        // 3. TWO COLUMN DYNAMIC
        // -----------------------------------------------------
        case .twoColumnDynamic(let detailForItem):

            let state = TwoColumnDynamicDetailState(
                left: baseState,
                detailForItem: detailForItem
            )
            let renderer = TwoColumnDynamicDetailRenderer<Item>()

            if isSingle {
                let behavior = TwoColumnDynamicDetailSingleBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            } else {
                let behavior = TwoColumnDynamicDetailMultiBehavior<Item>()
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

struct MultiSelectionBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = SelectionState<Item>

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let selected = state.options
                .filter { $0.isSelected }
                .map { $0.item }
            return .finishMulti(selected)

        case .space:
            state.toggleSelection(at: state.activeIndex)
            return .continueLoop

        case .quit:
            return .finishMulti([])

        case .backspace:
            return .continueLoop
        }
    }
}

struct TwoColumnStaticTextMultiBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = TwoColumnStaticTextState<Item>

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let selected = state.options
                .filter { $0.isSelected }
                .map { $0.item }
            return .finishMulti(selected)

        case .space:
            state.toggleSelection(at: state.activeIndex)
            return .continueLoop

        case .quit:
            return .finishMulti([])

        case .backspace:
            return .continueLoop
        }
    }
}

struct TwoColumnDynamicDetailMultiBehavior<Item: DisplayablePickerItem>: SelectionBehavior {
    typealias State = TwoColumnDynamicDetailState<Item>

    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let selected = state.options
                .filter { $0.isSelected }
                .map { $0.item }
            return .finishMulti(selected)

        case .space:
            state.toggleSelection(at: state.activeIndex)
            return .continueLoop

        case .quit:
            return .finishMulti([])

        case .backspace:
            return .continueLoop
        }
    }
}
