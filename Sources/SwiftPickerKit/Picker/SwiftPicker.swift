//
//  SwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public struct SwiftPicker {
    internal let textInput: TextInput
    internal let pickerInput: PickerInput

    /// Called when an interrupted prompt finishes, before it returns; `nil` finishes as cancelled
    /// straight away. See `PickerInterruptBehavior`.
    internal let waitForTermination: (() -> Void)?

    /// When `true`, permission prompts return `true` without asking. See
    /// `init(interruptBehavior:assumeYes:)`.
    internal let assumeYes: Bool

    internal init(textInput: TextInput, pickerInput: PickerInput, waitForTermination: (() -> Void)?, assumeYes: Bool) {
        self.textInput = textInput
        self.pickerInput = pickerInput
        self.waitForTermination = waitForTermination
        self.assumeYes = assumeYes
    }
}

// MARK: - Init
public extension SwiftPicker {
    /// Creates a picker whose interrupted prompts finish as if the user quit
    /// (`PickerInterruptBehavior.finishAsCancelled`).
    init() {
        self.init(interruptBehavior: .finishAsCancelled)
    }

    /// Creates a picker with the given response to a prompt interrupted by Ctrl+C or SIGTERM
    /// while the host keeps running.
    ///
    /// Permission prompts are always asked; use `init(interruptBehavior:assumeYes:)` to approve
    /// them automatically.
    ///
    /// - Parameter interruptBehavior: Whether interrupted prompts finish as cancelled or wait for
    ///   the host to end the process
    init(interruptBehavior: PickerInterruptBehavior) {
        self.init(interruptBehavior: interruptBehavior, assumeYes: false)
    }

    /// Creates a picker with the given interrupt response that can treat every permission prompt
    /// as approved, as a `--yes` command line flag usually promises.
    ///
    /// When `assumeYes` is `true`, `getPermission(prompt:)` returns `true` without printing or
    /// reading anything, so `requiredPermission` never throws. Text input, secret input,
    /// selection, and tree navigation still prompt as usual.
    ///
    /// - Parameters:
    ///   - interruptBehavior: Whether interrupted prompts finish as cancelled or wait for the host
    ///     to end the process
    ///   - assumeYes: Whether permission prompts are approved without asking
    init(interruptBehavior: PickerInterruptBehavior, assumeYes: Bool) {
        self.init(interruptBehavior: interruptBehavior, assumeYes: assumeYes, permissionSubmitMode: .requireEnter)
    }

    /// Creates a picker with the given interrupt response, `assumeYes` setting, and way of
    /// accepting answers to permission prompts.
    ///
    /// Pass `.immediate` to take a permission answer as soon as `y` or `n` is pressed, instead of
    /// waiting for Enter. When `assumeYes` is `true`, permission prompts are never shown, so
    /// `permissionSubmitMode` has no effect.
    ///
    /// - Parameters:
    ///   - interruptBehavior: Whether interrupted prompts finish as cancelled or wait for the host
    ///     to end the process
    ///   - assumeYes: Whether permission prompts are approved without asking
    ///   - permissionSubmitMode: Whether a permission answer needs Enter or is taken on the keypress
    init(interruptBehavior: PickerInterruptBehavior, assumeYes: Bool, permissionSubmitMode: PermissionSubmitMode) {
        let waitForTermination: (() -> Void)? = switch interruptBehavior {
        case .finishAsCancelled: nil
        case .waitForTermination: { SignalHandler.parkUntilTermination() }
        }

        self.init(textInput: DefaultTextInput(permissionSubmitMode: permissionSubmitMode), pickerInput: DefaultPickerInput(), waitForTermination: waitForTermination, assumeYes: assumeYes)
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
