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


// MARK: - Dependencies
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

// MARK: - Dependencies

/// An enumeration representing direction keys (up, down, left, right).
internal enum Direction {
    case up, down, left, right
}

/// An enumeration representing special characters (enter, space, quit, backspace).
internal enum SpecialChar {
    case enter, space, quit, backspace
}

public protocol PickerPrompt {
    var title: String { get }
}

extension String: PickerPrompt {
    public var title: String {
        return self
    }
}

public enum SwiftPickerError: Error {
    case inputRequired
    case selectionCancelled
}

public protocol DisplayablePickerItem {
    var displayName: String { get }
}

extension String: DisplayablePickerItem {
    public var displayName: String { self }
}

struct SelectionHandlerFactory {
    private let pickerInput: PickerInput
    
    init(pickerInput: PickerInput) {
        self.pickerInput = pickerInput
    }
}

extension SelectionHandlerFactory {
    
}
