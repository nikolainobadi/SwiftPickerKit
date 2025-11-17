//
//  SwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public struct SwiftPicker {
    let textInput: TextInput
    let pickerInput: PickerInput
    
    init(textInput: TextInput, pickerInput: PickerInput) {
        self.textInput = textInput
        self.pickerInput = pickerInput
    }
}


// MARK: - Init
public extension SwiftPicker {
    init() {
        self.init(textInput: DefaultTextInput(), pickerInput: DefaultPickerInput())
    }
}


// MARK: - High-Level API
public extension SwiftPicker {
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], newScreen: Bool = true) -> Item? {
        let behavior = SingleSelectionBehavior<Item>()
        let outcome = runSelection(prompt: prompt, items: items, behavior: behavior, isSingle: true, newScreen: newScreen)
        
        switch outcome {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], newScreen: Bool = true) throws -> Item {
        guard let value = singleSelection(prompt: prompt, items: items, newScreen: newScreen) else {
            throw SwiftPickerError.selectionCancelled
        }
        
        return value
    }

    func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], newScreen: Bool = true) -> [Item] {
        let behavior = MultiSelectionBehavior<Item>()
        let outcome = runSelection(prompt: prompt, items: items, behavior: behavior, isSingle: false, newScreen: newScreen)
        
        switch outcome {
        case .finishMulti(let items):
            return items
        default:
            return []
        }
    }
}


// MARK: - Core Selection Runner
internal extension SwiftPicker {
    @discardableResult
    func runSelection<Item, B: SelectionBehavior>(
        prompt: String,
        items: [Item],
        behavior: B,
        isSingle: Bool,
        newScreen: Bool
    ) -> SelectionOutcome<Item>
    where
        B.Item == Item,
        B.State == SelectionState<Item>,
        Item: DisplayablePickerItem
    {
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }
        
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()
        
        // No more topLine, no more line-based options
        let options = items.map { Option(item: $0) }

        let state = SelectionState(
            options: options,
            prompt: prompt,
            isSingleSelection: isSingle
        )
        
        let handler = SelectionHandler(
            state: state,
            pickerInput: pickerInput,
            behavior: behavior,
            renderer: SingleColumnRenderer<Item>()
        )
        
        let outcome = handler.captureUserInput()
        handler.endSelection()
        return outcome
    }
}


// MARK: - Dependencies (unchanged)
enum Direction { case up, down, left, right }
enum SpecialChar { case enter, space, quit, backspace }

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
