//
//  InteractivePicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public struct InteractivePicker {
    let textInput: TextInput
    let pickerInput: PickerInput
    
    init(textInput: TextInput, pickerInput: PickerInput) {
        self.textInput = textInput
        self.pickerInput = pickerInput
    }
}


// MARK: - Init
public extension InteractivePicker {
    init() {
        self.init(textInput: DefaultTextInput(), pickerInput: DefaultPickerInput())
    }
}


// MARK: - Helper Methods
internal extension InteractivePicker {
    @discardableResult
    func runSelection<Item, B: SelectionBehavior>(
        title: PickerPrompt,
        items: [Item],
        behavior: B,
        isSingle: Bool,
        newScreen: Bool
    ) -> SelectionOutcome<Item> where B.Item == Item, Item: DisplayablePickerItem {
        
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }
        
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()
        
        let topLine = pickerInput.readCursorPos().row + PickerPadding.top
        let options = items.enumerated().map { Option(item: $1, line: topLine + $0) }
        let state = SelectionState(
            options: options,
            topLine: topLine,
            title: title.title,
            isSingleSelection: isSingle
        )
        
        let handler = SelectionHandler(state: state, inputHandler: pickerInput, behavior: behavior)
        let outcome = handler.captureUserInput()
        
        handler.endSelection()
        
        return outcome
    }
}


// MARK: - Dependencies
enum Direction {
    case up, down, left, right
}

enum SpecialChar {
    case enter, space, quit, backspace
}

protocol TextInput {
    func getInput(_ prompt: String) -> String
    func getPermission(_ prompt: String) -> Bool
}

protocol PickerInput {
    func cursorOff()
    func moveRight()
    func moveToHome()
    func clearBuffer()
    func clearScreen()
    func enableNormalInput()
    func keyPressed() -> Bool
    func write(_ text: String)
    func exitAlternativeScreen()
    func enterAlternativeScreen()
    func moveTo(_ row: Int, _ col: Int)
    func readDirectionKey() -> Direction?
    func readSpecialChar() -> SpecialChar?
    func readCursorPos() -> (row: Int, col: Int)
    func readScreenSize() -> (rows: Int, cols: Int)
}
