//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Runs the input loop shared by every picker mode, wiring a State, Behavior, and Renderer together.
///
/// Owns rendering, scrolling, signal handling, and terminal restore; the components decide
/// what is shown, how input changes it, and how it is drawn.
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

    private let contentRenderer: Renderer

    /// Focused item, cached each frame for the header and its height calculation.
    private var currentSelectedItem: Item?

    private let waitForTermination: (() -> Void)?

    /// - Parameter waitForTermination: Called when SIGINT/SIGTERM ends the prompt but the process
    ///   keeps running, before the loop finishes as cancelled; `nil` finishes straight away.
    init(
        state: Behavior.State,
        pickerInput: PickerInput,
        behavior: Behavior,
        renderer: Renderer,
        waitForTermination: (() -> Void)?
    ) {
        self.state = state
        self.behavior = behavior
        self.pickerInput = pickerInput
        self.waitForTermination = waitForTermination

        self.headerRenderer = .init(pickerInput: pickerInput)
        self.footerRenderer = .init(pickerInput: pickerInput)
        self.contentRenderer = renderer
    }
}

// MARK: - Input Loop
extension SelectionHandler {
    /// Runs the input loop until the behavior finishes the selection.
    ///
    /// Installs SIGINT/SIGTERM handlers that restore the terminal so an interrupt never leaves
    /// it unusable. If the host handles the signal and the process keeps running, the loop
    /// finishes with the same outcome as pressing `q`.
    ///
    /// - Returns: The outcome reported by the behavior, or its `q` outcome after an interrupt.
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
            // A host that handles SIGINT/SIGTERM itself keeps the process running after the
            // terminal is restored; stop drawing, wait for the host if asked to, and otherwise
            // finish as if the user had quit
            if SignalHandler.wasInterrupted {
                waitForTermination?()
                return behavior.handleSpecialChar(char: .quit, state: state)
            }

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

    /// Exits the alternate screen and restores normal input; `captureUserInput` calls it on every exit path.
    func endSelection() {
        pickerInput.exitAlternativeScreen()
        pickerInput.enableNormalInput()
    }

    /// Lets the behavior apply an arrow key to the state, then redraws.
    func handleArrowKeys() {
        guard let dir = pickerInput.readDirectionKey() else { return }

        behavior.handleArrow(direction: dir, state: &state)

        renderFrame()
    }
}

// MARK: - Rendering
private extension SelectionHandler {
    var footerHeight: Int {
        return footerRenderer.height()
    }

    /// Header height in rows, which sets how many rows remain for content.
    ///
    /// Must mirror `PickerHeaderRenderer.renderHeader()` row for row; keep the two in sync.
    var headerHeight: Int {
        var height = 0
        height += 1 // top line

        if state.showPromptText {
            height += 1 // divider
            height += state.prompt.split(
                separator: "\n",
                omittingEmptySubsequences: false
            ).count
            height += 1 // blank after prompt
        } else {
            height += 1 // blank after top line
        }

        if state.showSelectedItemText && currentSelectedItem != nil {
            height += 3 // divider + "Selected:" + divider
            height += state.selectedDetailLines.count
            height += 1 // blank after selected block
        }

        height += 1 // spacer before content list
        return height
    }

    /// Redraws the whole picker after any state change.
    ///
    /// Content gets the rows left after the header and footer (at least one), and
    /// `ScrollEngine` picks the slice that keeps the active item visible.
    func renderFrame() {
        let (rows, cols) = pickerInput.readScreenSize()

        let options = state.options
        if let focusAware = state as? any FocusAwareSelectionState<Item> {
            // Tree navigation can focus the parent column, so activeIndex isn't enough
            currentSelectedItem = focusAware.focusedItem
        } else {
            if options.indices.contains(state.activeIndex) {
                currentSelectedItem = options[state.activeIndex].item
            } else {
                currentSelectedItem = nil
            }
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
            showSelectedItemText: state.showSelectedItemText,
            showPromptText: state.showPromptText,
            screenWidth: cols
        )

        let context = ScrollRenderContext(
            startIndex: start,
            endIndex: end,
            listStartRow: headerH,
            visibleRowCount: visibleRows
        )
        let items = options.map { $0.item }
        contentRenderer.render(
            items: items,
            state: state,
            context: context,
            input: pickerInput,
            screenWidth: cols
        )

        footerRenderer.renderFooter(instructionText: state.bottomLineText)

        // Drawn last, by the content renderer, so column layouts can position arrows per column
        contentRenderer.renderScrollIndicators(
            showUp: showUp,
            showDown: showDown,
            state: state,
            context: context,
            input: pickerInput,
            screenWidth: cols,
            headerHeight: headerH,
            totalRows: rows
        )
    }
}

// MARK: - Dependencies
/// What a behavior returns after handling input: keep looping, or finish with a result.
enum SelectionOutcome<Item> {
    case continueLoop

    /// `nil` when the user cancelled.
    case finishSingle(Item?)

    case finishMulti([Item])
}

/// Draws a picker layout's item list, limited to the visible slice in `ScrollRenderContext`.
protocol ContentRenderer {
    associatedtype State
    associatedtype Item: DisplayablePickerItem

    /// Draws the visible slice of `items` into the content area that starts at `context.listStartRow`.
    func render(items: [Item], state: State, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int)

    /// Draws the up/down scroll arrows when content overflows; column layouts override the default to place them per column.
    func renderScrollIndicators(showUp: Bool, showDown: Bool, state: State, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int, headerHeight: Int, totalRows: Int)
}

extension ContentRenderer {
    /// Puts the up arrow on the row above the content and the down arrow on the footer's first row.
    func renderScrollIndicators(showUp: Bool, showDown: Bool, state: State, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int, headerHeight: Int, totalRows: Int) {
        let scrollRenderer = ScrollRenderer(pickerInput: input)
        let footerRenderer = PickerFooterRenderer(pickerInput: input)

        if showUp {
            let arrowRow = headerHeight - 1
            scrollRenderer.renderUpArrow(at: arrowRow)
        }

        if showDown {
            let footerStartRow = totalRows - footerRenderer.height()
            scrollRenderer.renderDownArrow(at: footerStartRow)
        }
    }
}

/// Maps key input to state changes and decides when the selection finishes.
protocol SelectionBehavior {
    associatedtype Item: DisplayablePickerItem
    associatedtype State: BaseSelectionState<Item>

    /// Applies an arrow key to `state`.
    func handleArrow(direction: Direction, state: inout State)

    /// Handles Enter, Space, q, or Backspace and returns whether to keep looping or finish.
    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item>
}

extension SelectionBehavior {
    /// Moves up/down, stopping at either end without wrapping; left/right are ignored.
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
