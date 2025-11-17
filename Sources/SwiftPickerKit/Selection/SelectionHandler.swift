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
                    switch behavior.handleSpecialChar(char: special, state: state) {
                    case .continueLoop:
                        renderFrame()
                        continue
                    case .finishSingle, .finishMulti:
                        return behavior.handleSpecialChar(char: special, state: state)
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

    // Aligns with what PickerHeaderRenderer draws
    var headerHeight: Int {
        var height = 0
        
        height += 1 // topLineText
        height += 1 // divider
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
    
    var footerHeight: Int { footerRenderer.height() }
    
    var totalReservedSpace: Int { headerHeight + footerHeight }

    func renderFrame() {
        let (rows, cols) = pickerInput.readScreenSize()
        
        let displayable = rows - totalReservedSpace
        let start = max(0, state.activeLine - displayable)
        let end = min(start + displayable, state.options.count)
        
        currentSelectedItem = state.options.first(where: { $0.line == state.activeLine })?.item
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
        
        let max = screenWidth - 4
        let text = PickerTextFormatter.truncate(option.title, maxWidth: max)
        
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


// MARK: - PickerFooterRenderer
struct PickerFooterRenderer {
    private let pickerInput: PickerInput
    
    /// Height of the footer block (number of rows)
    /// Adjust if you add more lines
    private let footerHeight: Int = 3   // ↓ arrow / blank / instructions
    
    init(pickerInput: PickerInput) {
        self.pickerInput = pickerInput
    }
}
 
extension PickerFooterRenderer {
    func height() -> Int {
        return footerHeight
    }
    
    /// Renders the footer anchored at the bottom of the terminal window.
    /// Replaces any content previously in the footer region.
    func renderFooter(
        showScrollDownIndicator: Bool,
        instructionText: String
    ) {
        let (rows, _) = pickerInput.readScreenSize()
        let startRow = max(0, rows - footerHeight)
        
        // Move cursor to the footer region
        pickerInput.moveTo(startRow, 0)
        
        // Clear footer region
        for _ in 0..<footerHeight {
            pickerInput.write("\u{1B}[2K")    // clear line
            pickerInput.write("\n")
        }
        
        // Return again to render footer lines
        pickerInput.moveTo(startRow, 0)
        
        // DOWN ARROW (if needed)
        if showScrollDownIndicator {
            pickerInput.write("↓".lightGreen + "\n")
        } else {
            pickerInput.write("\n")
        }
        
        // BLANK LINE
        pickerInput.write("\n")
        
        // INSTRUCTION TEXT
        pickerInput.write(instructionText)
    }
}
