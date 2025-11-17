//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

final class SelectionHandler<
    Item: DisplayablePickerItem,
    Behavior: SelectionBehavior,
    Renderer: ContentRenderer
> where
    Behavior.Item == Item,
    Renderer.Item == Item,
    Behavior.State == Renderer.State
{
    private let behavior: Behavior
    private let pickerInput: PickerInput
    private var state: Behavior.State

    private let headerRenderer: PickerHeaderRenderer
    private let footerRenderer: PickerFooterRenderer
    private let scrollRenderer: ScrollRenderer
    private let contentRenderer: Renderer

    private var currentSelectedItem: Item?

    init(
        state: Behavior.State,
        pickerInput: PickerInput,
        behavior: Behavior,
        renderer: Renderer
    ) {
        self.state = state
        self.behavior = behavior
        self.pickerInput = pickerInput

        self.headerRenderer = .init(pickerInput: pickerInput)
        self.footerRenderer = .init(pickerInput: pickerInput)
        self.scrollRenderer = .init(pickerInput: pickerInput)
        self.contentRenderer = renderer
    }
}

// MARK: Input Loop
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
                    let outcome = behavior.handleSpecialChar(
                        char: special,
                        state: state
                    )

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

        // Delegate movement to the behavior so more complex
        // layouts (two-column, file explorer, etc.) can control it.
        behavior.handleArrow(direction: dir, state: &state)

        renderFrame()
    }
}

// MARK: Rendering
private extension SelectionHandler {
    var footerHeight: Int {
        footerRenderer.height()
    }

    /// Must mirror PickerHeaderRenderer output.
    var headerHeight: Int {
        var height = 0
        height += 1 // top line
        height += 1 // divider
        height += state.prompt.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).count
        
        height += 1 // blank after prompt

        if currentSelectedItem != nil {
            height += 3 // divider + Selected + divider
            height += 1 // blank after selected block
        }

        height += 1 // spacer before list
        return height
    }

    func renderFrame() {
        let (rows, cols) = pickerInput.readScreenSize()

        let options = state.options
        if options.indices.contains(state.activeIndex) {
            currentSelectedItem = options[state.activeIndex].item
        } else {
            currentSelectedItem = nil
        }

        let headerH = headerHeight
        let footerH = footerHeight
        let visibleRows = max(1, rows - headerH - footerH)
        let engine = ScrollEngine(totalItems: options.count, visibleRows: visibleRows)
        let (start, end) = engine.bounds(activeIndex: state.activeIndex)
        let showUp = engine.showScrollUp(start: start)
        let showDown = engine.showScrollDown(end: end)

        headerRenderer.renderHeader(
            prompt: state.prompt,
            topLineText: state.topLineText,
            selectedItem: currentSelectedItem,
            selectedDetailLines: state.selectedDetailLines,
            screenWidth: cols
        )

        if showUp {
            let arrowRow = headerH - 1
            scrollRenderer.renderUpArrow(at: arrowRow)
        }

        let context = ScrollRenderContext(startIndex: start, endIndex: end, listStartRow: headerH, visibleRowCount: visibleRows)
        let items = options.map { $0.item }

        contentRenderer.render(items: items, state: state, context: context, input: pickerInput, screenWidth: cols)
        footerRenderer.renderFooter(instructionText: state.bottomLineText)

        if showDown {
            let footerStartRow = rows - footerH
            scrollRenderer.renderDownArrow(at: footerStartRow)
        }
    }
}


// MARK: - Dependencies
enum SelectionOutcome<Item> {
    case continueLoop
    case finishSingle(Item?)
    case finishMulti([Item])
}

protocol ContentRenderer {
    associatedtype State
    associatedtype Item: DisplayablePickerItem

    func render(items: [Item], state: State, context: ScrollRenderContext, input: PickerInput, screenWidth: Int)
}

protocol SelectionBehavior {
    associatedtype Item: DisplayablePickerItem
    associatedtype State: BaseSelectionState<Item>

    func handleArrow(direction: Direction, state: inout State)
    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item>
}

extension SelectionBehavior {
    // Default behavior for up/down navigation.
    func handleArrow(direction: Direction, state: inout State) {
        switch direction {
        case .up:
            if state.activeIndex > 0 {
                state.activeIndex -= 1
            }
        case .down:
            if state.activeIndex < state.options.count - 1 {
                state.activeIndex += 1
            }
        case .left, .right:
            break
        }
    }
}
