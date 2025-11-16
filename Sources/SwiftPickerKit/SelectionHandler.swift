//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionHandler<Item: DisplayablePickerItem, Behavior: SelectionBehavior> where Behavior.Item == Item {
    private let behavior: Behavior
    private let inputHandler: PickerInput
    private let state: SelectionState<Item>
    private let headerRenderer: PickerHeaderRenderer
    
    init(state: SelectionState<Item>, inputHandler: PickerInput, behavior: Behavior) {
        self.state = state
        self.inputHandler = inputHandler
        self.headerRenderer = PickerHeaderRenderer(inputHandler: inputHandler)
        self.behavior = behavior
    }
}


// MARK: - Actions
extension SelectionHandler {
    func captureUserInput() -> SelectionOutcome<Item> {
        SignalHandler.setupSignalHandlers { [inputHandler] in
            inputHandler.exitAlternativeScreen()
            inputHandler.enableNormalInput()
        }

        defer {
            SignalHandler.removeSignalHandlers()
            endSelection()
        }

        scrollAndRenderOptions()

        while true {
            inputHandler.clearBuffer()

            if inputHandler.keyPressed() {
                if let char = inputHandler.readSpecialChar() {
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
        inputHandler.exitAlternativeScreen()
        inputHandler.enableNormalInput()
    }

    func handleArrowKeys() {
        guard let direction = inputHandler.readDirectionKey() else { return }

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
        let (rows, cols) = inputHandler.readScreenSize()

        let reservedHeaderSpace = 1
        let displayableOptions = rows - verticalPadding - reservedHeaderSpace

        renderScrollableOptions(
            displayableOptionsCount: displayableOptions,
            columns: cols,
            rows: rows
        )
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
        inputHandler.write("\n")
        if state.options.count > displayableOptionsCount {
            if end < state.options.count {
                inputHandler.write("↓".lightGreen)
            }
        }
        inputHandler.write("\n")
        inputHandler.write(state.bottomLineText)
    }

    func truncate(_ text: String, maxWidth: Int) -> String {
        PickerTextFormatter.truncate(text, maxWidth: maxWidth)
    }

    func renderOption(option: Option<Item>, isActive: Bool, row: Int, col: Int, screenWidth: Int) {
        inputHandler.moveTo(row, col)
        inputHandler.moveRight()
        inputHandler.write(
            state.showAsSelected(option)
            ? "●".lightGreen
            : "○".foreColor(250)
        )
        inputHandler.moveRight()

        let maxWidth = screenWidth - 4
        let truncated = truncate(option.title, maxWidth: maxWidth)

        inputHandler.write(
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
