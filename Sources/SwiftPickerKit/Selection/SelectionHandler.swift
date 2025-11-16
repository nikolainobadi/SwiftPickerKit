//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionHandler<Item: DisplayablePickerItem, Behavior: SelectionBehavior> where Behavior.Item == Item {
    private let behavior: Behavior
    private let pickerInput: PickerInput
    private let state: SelectionState<Item>
    private let headerRenderer: PickerHeaderRenderer
    
    init(state: SelectionState<Item>, pickerInput: PickerInput, behavior: Behavior) {
        self.state = state
        self.behavior = behavior
        self.pickerInput = pickerInput
        self.headerRenderer = .init(pickerInput: pickerInput)
    }
}


// MARK: - Actions
extension SelectionHandler {
    func captureUserInput() -> SelectionOutcome<Item> {
        SignalHandler.setupSignalHandlers { [pickerInput] in
            pickerInput.exitAlternativeScreen()
            pickerInput.enableNormalInput()
        }

        defer {
            SignalHandler.removeSignalHandlers()
            endSelection()
        }

        scrollAndRenderOptions()

        while true {
            pickerInput.clearBuffer()

            if pickerInput.keyPressed() {
                if let char = pickerInput.readSpecialChar() {
                    let outcome = behavior.handleSpecialChar(
                        char: char,
                        state: state
                    )

                    switch outcome {
                    case .continueLoop:
                        scrollAndRenderOptions()
                        continue

                    case .finishSingle,
                         .finishMulti:
                        return outcome
                    }
                }

                handleArrowKeys()
            }
        }
    }
    
    func endSelection() {
        pickerInput.exitAlternativeScreen()
        pickerInput.enableNormalInput()
    }

    func handleArrowKeys() {
        guard let direction = pickerInput.readDirectionKey() else { return }

        switch direction {
        case .up:
            if state.activeLine > state.rangeOfLines.minimum {
                handleScrolling(direction: -1)
            }
        case .down:
            handleScrolling(direction: 1)
        case .left, .right:
            break
        }
    }

    func scrollAndRenderOptions() {
        let (rows, cols) = pickerInput.readScreenSize()
        let reservedHeaderSpace = 1
        let displayableOptions = rows - verticalPadding - reservedHeaderSpace

        renderScrollableOptions(displayableOptionsCount: displayableOptions, columns: cols, rows: rows)
    }
}


// MARK: - Private Helpers
private extension SelectionHandler {
    var topPadding: Int { PickerPadding.top }
    var bottomPadding: Int { PickerPadding.bottom }
    var verticalPadding: Int { topPadding + bottomPadding }

    func handleScrolling(direction: Int) {
        state.activeLine = max(0, min(state.options.count + topPadding, state.activeLine + direction))
        scrollAndRenderOptions()
    }

    func renderScrollableOptions(displayableOptionsCount: Int, columns: Int, rows: Int) {
        let start = max(0, state.activeLine - (displayableOptionsCount + topPadding))
        let end = min(start + displayableOptionsCount, state.options.count)

        let activeOption = state.options.first {
            $0.line == state.activeLine
        }

        headerRenderer.renderHeader(
            topLineText: state.topLineText,
            title: state.title,
            selectedItem: activeOption?.item,
            screenWidth: columns,
            showScrollUpIndicator: start > 0
        )

        for i in start..<end {
            let option = state.options[i]
            let row = i - start + (topPadding + 1)
            let isActive = option.line == state.activeLine
            renderOption(
                option: option,
                isActive: isActive,
                row: row,
                col: 0,
                screenWidth: columns
            )
        }

        renderFooter(end: end, displayableOptionsCount: displayableOptionsCount)
    }

    func renderFooter(end: Int, displayableOptionsCount: Int) {
        pickerInput.write("\n")
        if state.options.count > displayableOptionsCount {
            if end < state.options.count {
                pickerInput.write("↓".lightGreen)
            }
        }
        pickerInput.write("\n")
        pickerInput.write(state.bottomLineText)
    }

    func renderOption(option: Option<Item>, isActive: Bool, row: Int, col: Int, screenWidth: Int) {
        pickerInput.moveTo(row, col)
        pickerInput.moveRight()
        pickerInput.write(
            state.showAsSelected(option)
            ? "●".lightGreen
            : "○".foreColor(250)
        )
        pickerInput.moveRight()

        let maxWidth = screenWidth - 4
        let truncated = PickerTextFormatter.truncate(option.title, maxWidth: maxWidth)

        pickerInput.write(
            isActive
            ? truncated.underline
            : truncated.foreColor(250)
        )
    }
}


// MARK: - Dependencies
protocol SelectionBehavior {
    associatedtype Item: DisplayablePickerItem

    func handleSpecialChar(char: SpecialChar, state: SelectionState<Item>) -> SelectionOutcome<Item>
}

enum SelectionOutcome<Item> {
    case continueLoop
    case finishSingle(Item?)
    case finishMulti([Item])
}
