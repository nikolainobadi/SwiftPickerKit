//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

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
    private let scrollRenderer: ScrollRenderer

    private var currentSelectedItem: Item?

    init(state: SelectionState<Item>, pickerInput: PickerInput, behavior: Behavior) {
        self.state = state
        self.behavior = behavior
        self.pickerInput = pickerInput

        self.headerRenderer = .init(pickerInput: pickerInput)
        self.footerRenderer = .init(pickerInput: pickerInput)
        self.scrollRenderer = .init(pickerInput: pickerInput)
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
                // Special chars: enter / space / quit
                if let special = pickerInput.readSpecialChar() {
                    let outcome = behavior.handleSpecialChar(char: special, state: state)

                    switch outcome {
                    case .continueLoop:
                        renderFrame()
                        continue
                    case .finishSingle, .finishMulti:
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
        guard let dir = pickerInput.readDirectionKey() else { return }

        switch dir {
        case .up:
            if state.activeIndex > 0 {
                state.activeIndex -= 1
                renderFrame()
            }

        case .down:
            if state.activeIndex < state.options.count - 1 {
                state.activeIndex += 1
                renderFrame()
            }

        case .left, .right:
            break
        }
    }
}

// MARK: - Rendering

private extension SelectionHandler {

    var footerHeight: Int {
        footerRenderer.height()
    }

    /// Must mirror PickerHeaderRenderer's output structure.
    var headerHeight: Int {
        var height = 0
        height += 1 // top line
        height += 1 // divider
        height += state.prompt.split(separator: "\n", omittingEmptySubsequences: false).count
        height += 1 // blank after prompt

        if currentSelectedItem != nil {
            height += 3 // divider + "Selected" + divider
            height += 1 // blank after selected block
        }

        height += 1 // spacer before list
        return height
    }

    func renderFrame() {
        let (rows, cols) = pickerInput.readScreenSize()

        // Must set BEFORE computing headerHeight
        currentSelectedItem = state.options[state.activeIndex].item

        let headerH = headerHeight
        let footerH = footerHeight

        // Rows available strictly between header and footer
        let visibleRows = max(1, rows - headerH - footerH)

        let engine = ScrollEngine(
            totalItems: state.options.count,
            visibleRows: visibleRows
        )

        let (start, end) = engine.bounds(activeIndex: state.activeIndex)
        let showUp = engine.showScrollUp(start: start)
        let showDown = engine.showScrollDown(end: end)

        // ---------------------------------------------------------
        // HEADER (clears screen and moves to home)
        // ---------------------------------------------------------
        headerRenderer.renderHeader(
            prompt: state.prompt,
            topLineText: state.topLineText,
            selectedItem: currentSelectedItem,
            screenWidth: cols
        )

        // ---------------------------------------------------------
        // TOP SCROLL ARROW
        // ---------------------------------------------------------
        if showUp {
            let arrowRow = headerH - 1
            scrollRenderer.renderUpArrow(at: arrowRow)
        }

        // ---------------------------------------------------------
        // LIST ITEMS
        // ---------------------------------------------------------
        let listStartRow = headerH

        for (offset, index) in (start..<end).enumerated() {
            let option = state.options[index]
            let row = listStartRow + offset
            let isActive = (index == state.activeIndex)

            renderOption(
                option: option,
                isActive: isActive,
                row: row,
                col: 0,
                screenWidth: cols
            )
        }

        // ---------------------------------------------------------
        // FOOTER
        // ---------------------------------------------------------
        footerRenderer.renderFooter(
            instructionText: state.bottomLineText
        )

        // ---------------------------------------------------------
        // BOTTOM SCROLL ARROW
        // ---------------------------------------------------------
        if showDown {
            let footerStartRow = rows - footerH
            scrollRenderer.renderDownArrow(at: footerStartRow)
        }
    }

    func renderOption(option: Option<Item>, isActive: Bool, row: Int, col: Int, screenWidth: Int) {
        pickerInput.moveTo(row, col)
        pickerInput.moveRight()

        if state.isSingleSelection {
            pickerInput.write(isActive ? "●".lightGreen : "○".foreColor(250))
        } else {
            pickerInput.write(option.isSelected ? "●".lightGreen : "○".foreColor(250))
        }

        pickerInput.moveRight()

        let maxWidth = screenWidth - 4
        let text = PickerTextFormatter.truncate(option.title, maxWidth: maxWidth)

        if isActive {
            pickerInput.write(text.underline)
        } else {
            pickerInput.write(text.foreColor(250))
        }
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
