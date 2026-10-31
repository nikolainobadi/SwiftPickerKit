//
//  SwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public struct SwiftPicker {
    internal let textInput: TextInput
    internal let pickerInput: PickerInput

    /// Called when an interrupted selection prompt finishes, before it returns; `nil` finishes as
    /// cancelled straight away. See `PickerInterruptBehavior`.
    internal let waitForTermination: (() -> Void)?

    internal init(textInput: TextInput, pickerInput: PickerInput, waitForTermination: (() -> Void)?) {
        self.textInput = textInput
        self.pickerInput = pickerInput
        self.waitForTermination = waitForTermination
    }
}

// MARK: - Init
public extension SwiftPicker {
    /// Creates a picker whose interrupted selection prompts finish as if the user quit
    /// (`PickerInterruptBehavior.finishAsCancelled`).
    init() {
        self.init(interruptBehavior: .finishAsCancelled)
    }

    /// Creates a picker with the given response to a selection prompt interrupted by Ctrl+C or
    /// SIGTERM while the host keeps running.
    ///
    /// - Parameter interruptBehavior: Whether interrupted prompts finish as cancelled or wait for
    ///   the host to end the process
    init(interruptBehavior: PickerInterruptBehavior) {
        switch interruptBehavior {
        case .finishAsCancelled:
            self.init(textInput: DefaultTextInput(), pickerInput: DefaultPickerInput(), waitForTermination: nil)
        case .waitForTermination:
            self.init(textInput: DefaultTextInput(), pickerInput: DefaultPickerInput(), waitForTermination: { SignalHandler.parkUntilTermination() })
        }
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
    func getSecretInput(_ prompt: String) -> String
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
