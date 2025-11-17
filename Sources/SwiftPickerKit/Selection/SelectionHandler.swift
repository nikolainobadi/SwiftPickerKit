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

final class SelectionHandler<
    Item: DisplayablePickerItem,
    Behavior: SelectionBehavior,
    Renderer: ContentRenderer
> where Behavior.Item == Item, Renderer.Item == Item {

    private let behavior: Behavior
    private let pickerInput: PickerInput
    private let state: SelectionState<Item>

    private let headerRenderer: PickerHeaderRenderer
    private let footerRenderer: PickerFooterRenderer
    private let scrollRenderer: ScrollRenderer
    private let contentRenderer: Renderer

    private var currentSelectedItem: Item?

    init(
        state: SelectionState<Item>,
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

// MARK: Rendering

private extension SelectionHandler {

    var footerHeight: Int {
        footerRenderer.height()
    }

    /// Must mirror PickerHeaderRenderer output.
    var headerHeight: Int {
        var height = 0
        height += 1                         // top line
        height += 1                         // divider
        height += state.prompt.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).count
        height += 1                         // blank after prompt

        if currentSelectedItem != nil {
            height += 3                     // divider + Selected + divider
            height += 1                     // blank after selected block
        }

        height += 1                         // spacer before list
        return height
    }

    func renderFrame() {
        let (rows, cols) = pickerInput.readScreenSize()

        currentSelectedItem = state.options[state.activeIndex].item

        let headerH = headerHeight
        let footerH = footerHeight

        let visibleRows = max(1, rows - headerH - footerH)

        let engine = ScrollEngine(
            totalItems: state.options.count,
            visibleRows: visibleRows
        )

        let (start, end) = engine.bounds(activeIndex: state.activeIndex)
        let showUp = engine.showScrollUp(start: start)
        let showDown = engine.showScrollDown(end: end)

        headerRenderer.renderHeader(
            prompt: state.prompt,
            topLineText: state.topLineText,
            selectedItem: currentSelectedItem,
            screenWidth: cols
        )

        if showUp {
            let arrowRow = headerH - 1
            scrollRenderer.renderUpArrow(at: arrowRow)
        }

        let context = ScrollRenderContext(
            startIndex: start,
            endIndex: end,
            listStartRow: headerH,
            visibleRowCount: visibleRows
        )

        let items = state.options.map { $0.item }

        contentRenderer.render(
            items: items,
            state: state,
            context: context,
            using: pickerInput,
            screenWidth: cols
        )

        footerRenderer.renderFooter(
            instructionText: state.bottomLineText
        )

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

protocol SelectionBehavior {
    associatedtype Item: DisplayablePickerItem

    func handleSpecialChar(char: SpecialChar, state: SelectionState<Item>) -> SelectionOutcome<Item>
}

protocol ContentRenderer {
    associatedtype Item: DisplayablePickerItem
    func render(
        items: [Item],
        state: SelectionState<Item>,
        context: ScrollRenderContext,
        using input: PickerInput,
        screenWidth: Int
    )
}
