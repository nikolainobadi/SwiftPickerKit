public struct SwiftPicker {
    internal let textInput: TextInput
    internal let pickerInput: PickerInput

    /// Called when an interrupted prompt finishes, before it returns; `nil` finishes as cancelled
    /// straight away. See `PickerInterruptBehavior`.
    internal let waitForTermination: (() -> Void)?

    /// When `true`, permission prompts return `true` without asking. See
    /// `init(interruptBehavior:assumeYes:)`.
    internal let assumeYes: Bool

    /// Colors for the picker's chrome. See `init(interruptBehavior:assumeYes:permissionSubmitMode:theme:)`.
    internal let theme: PickerTheme

    /// Applies styles, dropping colors when standard output doesn't support them.
    internal let styler: PickerStyler

    internal init(textInput: TextInput, pickerInput: PickerInput, waitForTermination: (() -> Void)?, assumeYes: Bool, theme: PickerTheme, styler: PickerStyler) {
        self.textInput = textInput
        self.pickerInput = pickerInput
        self.waitForTermination = waitForTermination
        self.assumeYes = assumeYes
        self.theme = theme
        self.styler = styler
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
        self.init(interruptBehavior: interruptBehavior, assumeYes: assumeYes, permissionSubmitMode: permissionSubmitMode, theme: .standard)
    }

    /// Creates a picker that draws its markers, pointers, gray text, headers, and arrows in
    /// `theme`'s colors.
    ///
    /// Colors are left out when standard output isn't a terminal, `NO_COLOR` is set to a non-empty
    /// value, or `TERM` is `dumb`; bold, dim, and underline are still drawn so the active row stays
    /// visible. Items that conform to `StyledPickerItem` use their own style for their rows.
    ///
    /// - Parameters:
    ///   - interruptBehavior: Whether interrupted prompts finish as cancelled or wait for the host
    ///     to end the process
    ///   - assumeYes: Whether permission prompts are approved without asking
    ///   - permissionSubmitMode: Whether a permission answer needs Enter or is taken on the keypress
    ///   - theme: The colors for the picker's own chrome; pass `.standard` for the default look
    init(interruptBehavior: PickerInterruptBehavior, assumeYes: Bool, permissionSubmitMode: PermissionSubmitMode, theme: PickerTheme) {
        let waitForTermination: (() -> Void)? = switch interruptBehavior {
        case .finishAsCancelled: nil
        case .waitForTermination: { SignalHandler.parkUntilTermination() }
        }

        let styler = PickerStyler(colorEnabled: PickerColorSupport.isEnabledForStandardOutput)

        self.init(textInput: DefaultTextInput(permissionSubmitMode: permissionSubmitMode), pickerInput: DefaultPickerInput(), waitForTermination: waitForTermination, assumeYes: assumeYes, theme: theme, styler: styler)
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
