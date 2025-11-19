//
//  SwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public struct SwiftPicker {
    internal let textInput: TextInput
    internal let pickerInput: PickerInput
    
    internal init(textInput: TextInput, pickerInput: PickerInput) {
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


// MARK: - Dependencies (unchanged)
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
