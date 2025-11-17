//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionHandler<Item: DisplayablePickerItem, Behavior: SelectionBehavior>
where Behavior.Item == Item {

    private let behavior: Behavior
    private let pickerInput: PickerInput
    private let state: SelectionState<Item>

    private let headerRenderer: PickerHeaderRenderer
    private let footerRenderer: PickerFooterRenderer

    private var currentSelectedItem: Item?
    private var showScrollUp = false

    init(state: SelectionState<Item>, pickerInput: PickerInput, behavior: Behavior) {
        self.state = state
        self.behavior = behavior
        self.pickerInput = pickerInput

        self.headerRenderer = .init(pickerInput: pickerInput)
        self.footerRenderer = .init(pickerInput: pickerInput)
    }
}

// MARK: - Input Loop
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

        renderFrame()

        while true {
            pickerInput.clearBuffer()

            if pickerInput.keyPressed() {

                if let special = pickerInput.readSpecialChar() {

                    let outcome = behavior.handleSpecialChar(char: special, state: state)

                    switch outcome {

                    case .continueLoop:
                        renderFrame()
                        continue

                    case .finishSingle,
                         .finishMulti:
                        return outcome   // FIXED: no second call
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
        guard let dir = pickerInput.readDirectionKey() else { return }

        switch dir {
        case .up:
            if state.activeLine > state.rangeOfLines.minimum {
                state.activeLine -= 1
                renderFrame()
            }
        case .down:
            state.activeLine += 1
            renderFrame()
        case .left, .right:
            break
        }
    }
}

// MARK: - Rendering
private extension SelectionHandler {

    var headerHeight: Int {
        var height = 0

        height += 1 // topLineText
        height += 1 // divider

        // prompt lines
        height += state.prompt.split(separator: "\n", omittingEmptySubsequences: false).count

        height += 1 // divider
        height += 1 // blank line

        if currentSelectedItem != nil {
            height += 3 // divider + line + divider
            height += 1 // blank
        }

        if showScrollUp {
            height += 1 // ↑
        }

        height += 1 // final blank before list

        return height
    }

    var footerHeight: Int {
        footerRenderer.height()
    }

    var totalReservedSpace: Int {
        headerHeight + footerHeight
    }

    func renderFrame() {
        let (rows, cols) = pickerInput.readScreenSize()

        let displayable = rows - totalReservedSpace
        let start = max(0, state.activeLine - displayable)
        let end = min(start + displayable, state.options.count)

        currentSelectedItem = state.options.first { $0.line == state.activeLine }?.item
        showScrollUp = (start > 0)

        headerRenderer.renderHeader(
            prompt: state.prompt,
            topLineText: state.topLineText,
            selectedItem: currentSelectedItem,
            screenWidth: cols,
            showScrollUpIndicator: showScrollUp
        )

        for i in start..<end {
            let option = state.options[i]
            let row = i - start + headerHeight
            let isActive = option.line == state.activeLine

            renderOption(option: option, isActive: isActive, row: row, col: 0, screenWidth: cols)
        }

        let showDown = end < state.options.count

        footerRenderer.renderFooter(
            showScrollDownIndicator: showDown,
            instructionText: state.bottomLineText
        )
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
        let text = PickerTextFormatter.truncate(option.title, maxWidth: maxWidth)

        pickerInput.write(isActive ? text.underline : text.foreColor(250))
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
