//
//  TwoColumnStaticTextState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

final class TwoColumnStaticTextState<Item: DisplayablePickerItem> {
    var left: SelectionState<Item>
    var rightTextLines: [String]

    init(left: SelectionState<Item>, rightText: String) {
        self.left = left
        self.rightTextLines = rightText.split(separator: "\n").map(String.init)
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

struct TwoColumnStaticTextRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    typealias State = TwoColumnStaticTextState<Item>

    func render(
        items: [Item],
        state: State,
        context: ScrollRenderContext,
        input: PickerInput,
        screenWidth: Int
    ) {
        let leftWidth = screenWidth / 2
        let rightWidth = screenWidth - leftWidth

        var row = context.listStartRow

        // left side uses visible item indices
        for index in context.startIndex..<context.endIndex {
            let option = state.left.options[index]
            let isActive = (index == state.left.activeIndex)

            input.moveTo(row, 0)
            input.moveRight()

            let marker: String
            if state.left.isSingleSelection {
                marker = isActive ? "●".lightGreen : "○".foreColor(250)
            } else {
                marker = option.isSelected ? "●".lightGreen : "○".foreColor(250)
            }
            input.write(marker)
            input.moveRight()

            let maxLeftWidth = leftWidth - 4
            let leftText = PickerTextFormatter.truncate(option.title, maxWidth: maxLeftWidth)
            if isActive { input.write(leftText.underline) }
            else { input.write(leftText.foreColor(250)) }

            // right side shows static text lines, independent of selection
            let visualRow = row - context.listStartRow
            if visualRow < state.rightTextLines.count {
                let line = state.rightTextLines[visualRow]
                let truncated = PickerTextFormatter.truncate(line, maxWidth: rightWidth - 3)

                input.moveTo(row, leftWidth)
                input.write("│".foreColor(240))
                input.moveRight()
                input.write(truncated.foreColor(250))
            }

            row += 1
        }
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
        }
    }
}
