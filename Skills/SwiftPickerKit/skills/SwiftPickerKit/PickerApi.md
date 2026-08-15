# Picker API

Core protocols, entry point, layout options, and error types for SwiftPickerKit's interactive terminal pickers.

---

## Protocol: DisplayablePickerItem

All items displayed in pickers must conform to this protocol.

```swift
public protocol DisplayablePickerItem {
    var displayName: String { get }
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `displayName` | `String` | Text displayed for this item in the picker |

### Usage Example

```swift
struct MenuItem: DisplayablePickerItem {
    let displayName: String
    let action: () -> Void
}
```

> **Note:** `String` has a built-in conformance (`displayName` returns `self`), so `[String]` arrays work directly with all picker methods.

---

## Protocol: CommandLineInput

Text input from the terminal.

```swift
public protocol CommandLineInput {
    func getInput(prompt: String) -> String
}
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getInput(prompt:)` | `String` | Reads a line of text input; returns empty string if user enters nothing |
| `getInput(_:)` | `String` | Convenience overload with unlabeled prompt |
| `getRequiredInput(prompt:) throws` | `String` | Throws `SwiftPickerError.inputRequired` if input is empty |
| `getRequiredInput(_:) throws` | `String` | Convenience overload with unlabeled prompt |
| `getRequiredInput(prompt:flagHint:) throws` | `String` | Throws `PickerRequirementError.missingInput` naming the CLI flag that supplies the value |

### Input Behavior

`getRequiredInput` checks `input.isEmpty` — whitespace-only strings pass validation. No terminal screen manipulation occurs; uses standard readline.

### Usage Example

```swift
func configure(picker: some CommandLineInput) throws {
    let name = try picker.getRequiredInput(prompt: "Project name: ")
    let description = picker.getInput(prompt: "Description (optional): ")
}
```

---

## Protocol: CommandLinePermission

Yes/no confirmation from the terminal.

```swift
public protocol CommandLinePermission {
    func getPermission(prompt: String) -> Bool
}
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getPermission(prompt:)` | `Bool` | Returns true for yes, false for no |
| `getPermission(_:)` | `Bool` | Convenience overload with unlabeled prompt |
| `requiredPermission(prompt:) throws` | `Void` | Throws `SwiftPickerError.selectionCancelled` when permission denied |
| `requiredPermission(_:) throws` | `Void` | Convenience overload with unlabeled prompt |
| `requiredPermission(prompt:flagHint:) throws` | `Void` | Throws `PickerRequirementError.confirmationRequired` naming the CLI flag that grants consent |

### Usage Example

```swift
func dangerousAction(picker: some CommandLinePermission) throws {
    try picker.requiredPermission(prompt: "Delete all data? (y/n): ")
    // Only reached if user confirmed
}
```

---

## Protocol: CommandLineSelection

Single and multi-selection pickers with layout support.

```swift
public protocol CommandLineSelection {
    func singleSelection<Item: DisplayablePickerItem>(
        prompt: String, items: [Item], layout: PickerLayout<Item>,
        newScreen: Bool, showSelectedItemText: Bool
    ) -> Item?

    func multiSelection<Item: DisplayablePickerItem>(
        prompt: String, items: [Item], layout: PickerLayout<Item>,
        newScreen: Bool, showSelectedItemText: Bool
    ) -> [Item]
}
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `singleSelection(prompt:items:layout:newScreen:showSelectedItemText:)` | `Item?` | User picks one item; `nil` if cancelled (quit key) |
| `singleSelection(_:items:layout:newScreen:showSelectedItemText:)` | `Item?` | Convenience with unlabeled prompt |
| `requiredSingleSelection(prompt:items:layout:newScreen:showSelectedItemText:) throws` | `Item` | Throws `.selectionCancelled` if user quits |
| `requiredSingleSelection(_:items:layout:newScreen:showSelectedItemText:) throws` | `Item` | Convenience with unlabeled prompt |
| `multiSelection(prompt:items:layout:newScreen:showSelectedItemText:)` | `[Item]` | User toggles items with space, confirms with enter; empty array if cancelled |
| `multiSelection(_:items:layout:newScreen:showSelectedItemText:)` | `[Item]` | Convenience with unlabeled prompt |
| `requiredSingleSelection(prompt:items:flagHint:layout:newScreen:showSelectedItemText:) throws` | `Item` | Throws `PickerRequirementError.missingSelection` naming the CLI flag that supplies the choice |
| `requiredMultiSelection(prompt:items:flagHint:layout:newScreen:showSelectedItemText:) throws` | `[Item]` | Throws `PickerRequirementError.missingSelection` when the result is empty |

### Default Parameter Values

- `layout: .singleColumn`
- `newScreen: true`
- `showSelectedItemText: true`

> **Careful:** these defaults are **not** applied uniformly. The labeled
> `requiredSingleSelection(prompt:items:layout:newScreen:showSelectedItemText:)` declares **no**
> default values, so `requiredSingleSelection(prompt:items:)` does not compile. Only the unlabeled
> `requiredSingleSelection(_:items:)` and the `flagHint:` overload carry defaults. The non-throwing
> `singleSelection` / `multiSelection` carry them in both labeled and unlabeled forms.

### Empty Multi-Selection Is Ambiguous

`multiSelection` returns `[]` both when the user deliberately selected nothing and when nothing
could be prompted for. Use `requiredMultiSelection(prompt:items:flagHint:)` when an empty result
should be an error rather than a silent "zero items" — this matters most under
`NonInteractivePicker`, where every multi-selection returns `[]`.

### Selection Behavior

**Single mode:** Arrow keys navigate, enter selects the highlighted item, space does nothing, quit returns `nil`.

**Multi mode:** Arrow keys navigate, space toggles selection on highlighted item, enter confirms all toggled items, quit discards all selections and returns `[]`.

**Screen handling:** When `newScreen: true`, enters the terminal's alternative screen buffer (preserves original terminal content). When `false`, draws directly in the current buffer. On exit, `exitAlternativeScreen()` and `enableNormalInput()` are always called regardless of `newScreen` value.

### Usage Example

```swift
let picker = SwiftPicker()
let colors = ["Red", "Green", "Blue"]

// Single selection
guard let chosen = picker.singleSelection(prompt: "Pick a color:", items: colors) else {
    print("Cancelled")
    return
}

// Multi selection with two-column layout
let selected = picker.multiSelection(
    prompt: "Select colors:",
    items: colors,
    layout: .twoColumnStatic(detailText: "Choose one or more colors from the list.")
)
```

---

## Enum: PickerLayout

Controls the visual layout of selection pickers.

```swift
public enum PickerLayout<Item: DisplayablePickerItem> {
    case singleColumn
    case twoColumnStatic(detailText: String)
    case twoColumnDynamic(detailForItem: (Item) -> String)
}
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `singleColumn` | None | Vertical list of items |
| `twoColumnStatic` | `detailText: String` | Left column items, right column shows fixed text |
| `twoColumnDynamic` | `detailForItem: (Item) -> String` | Left column items, right column updates per highlighted item |

### Layout Rendering Details

- **Column widths:** Left = `max(18, screenWidth / 3)`, right = remaining space minus 3
- **Dynamic detail:** The closure is called on every render frame with the currently highlighted item
- **Static text:** Word-wrapped once per render to fit the right column width

### Usage Example

```swift
struct Feature: DisplayablePickerItem {
    let displayName: String
    let detail: String
}

let features: [Feature] = [...]
let layout: PickerLayout<Feature> = .twoColumnDynamic { item in item.detail }
let selected = picker.singleSelection(prompt: "Select feature:", items: features, layout: layout)
```

---

## Enum: PickerDividerStyle

Divider line styles used in picker rendering.

```swift
public enum PickerDividerStyle {
    case single    // ────────
    case double    // ========
    case dashed    // - - - -
    case none      // (empty)
    case custom(String)
}
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `single` | None | Repeating `─` character |
| `double` | None | Repeating `=` character |
| `dashed` | None | Repeating `- ` pattern |
| `none` | None | Empty string (no divider) |
| `custom` | `String` | Repeating the provided token |

---

## Enum: SwiftPickerError

Errors thrown by required/throwing variants of picker methods.

```swift
public enum SwiftPickerError: Error {
    case inputRequired
    case selectionCancelled
}
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `inputRequired` | None | Thrown by `getRequiredInput` when input string is empty |
| `selectionCancelled` | None | Thrown by `requiredSingleSelection`, `requiredPermission`, `requiredTreeNavigation` when user quits |

> `SwiftPickerError` is a public non-frozen enum in a package without library evolution, so
> downstream exhaustive `switch`es compile without `@unknown default`. Adding a case is
> source-breaking — that is why the `flagHint:` overloads throw a separate type.

---

## Enum: PickerRequirementError

Thrown by the `flagHint:` variants of the `required*` methods.

```swift
public enum PickerRequirementError: Error, LocalizedError {
    case missingInput(prompt: String, flagHint: String?)
    case missingSelection(prompt: String, flagHint: String?)
    case confirmationRequired(prompt: String, flagHint: String?)
}
```

### Cases

| Case | Thrown by | Rendered message |
|------|-----------|------------------|
| `missingInput` | `getRequiredInput(prompt:flagHint:)` | `Missing required value for "Project name". Pass --name.` |
| `missingSelection` | `requiredSingleSelection` / `requiredMultiSelection` / `requiredTreeNavigation` with `flagHint:` | `No selection made for "Choose a target". Pass --target.` |
| `confirmationRequired` | `requiredPermission(prompt:flagHint:)` | `Confirmation required for "Delete all builds?". Pass --force.` |

When `flagHint` is `nil` the message ends `Provide it as an argument.`, except
`confirmationRequired`, which falls back to `Pass --yes.`

### Mode Neutrality

These overloads fire for a live `SwiftPicker` too — pressing Enter at an empty prompt throws
`missingInput` just as a scripted run does. The messages deliberately never mention interactive or
non-interactive mode so they read correctly in both cases.

### Two Error Types On One Call Path

Adopting `flagHint:` incrementally leaves some calls throwing `SwiftPickerError` and others
`PickerRequirementError`. Catch both, or catch `Error` and render `localizedDescription` —
`PickerRequirementError` conforms to `LocalizedError` so it prints its message; `SwiftPickerError`
does not, so it prints its case name.

---

## Struct: NonInteractivePicker

A `CommandLinePicker` that never prompts, for scripted, piped, or CI contexts.

```swift
public struct NonInteractivePicker: CommandLinePicker, Sendable {
    public init(assumeYes: Bool = false)
}
```

### Behavior

| Call | Result |
|------|--------|
| `getInput(prompt:)` | `""` |
| `getRequiredInput(prompt:)` | throws `SwiftPickerError.inputRequired` |
| `getPermission(prompt:)` | `assumeYes` |
| `requiredPermission(prompt:)` | throws `SwiftPickerError.selectionCancelled` unless `assumeYes` |
| `singleSelection(...)` | `nil` |
| `requiredSingleSelection(...)` | throws `SwiftPickerError.selectionCancelled` |
| `multiSelection(...)` | `[]` |
| `treeNavigation(...)` | `nil` |
| `browseDirectories(...)` | `nil` |

The throwing behavior is inherited, not reimplemented: the `required*` methods are protocol
extensions that call the primitives, so returning "nothing" from the six primitives produces all of
it.

### Guarantees

Never blocks and never waits on a human — no terminal I/O, no signal handlers, no alternate screen
buffer. Every method returns immediately, and the type is `Sendable`.

### browseDirectories Caveat

`browseDirectories` always returns `nil`, but reaching it through `any CommandLinePicker` or a
generic `some CommandLinePicker` **with the trailing arguments omitted** binds to the convenience
overload in `CommandLineTreeNavigation`, not to the struct's own member. That overload reads one
directory listing from disk and assigns `FileSystemNode.selectionType` before delegating. Only the
return value is unaffected.

This cannot be prevented from outside `CommandLineTreeNavigation`: default arguments on a protocol
extension member bind statically, and the protocol requirement declares none. Pass every argument
explicitly, or hold a concrete `NonInteractivePicker`, to avoid it.

### Usage Example

```swift
let picker: any CommandLinePicker = isInteractive
    ? SwiftPicker()
    : NonInteractivePicker(assumeYes: assumeYes)

let name = try picker.getRequiredInput(prompt: "Project name", flagHint: "--name")
```

---

## Typealias: CommandLinePicker

Combines all four interaction protocols into a single dependency type.

```swift
public typealias CommandLinePicker = CommandLineInput & CommandLinePermission & CommandLineSelection & CommandLineTreeNavigation
```

### Usage Example

```swift
class AppCoordinator {
    let picker: CommandLinePicker

    init(picker: CommandLinePicker) {
        self.picker = picker
    }
}

// Production
let coordinator = AppCoordinator(picker: SwiftPicker())

// Scripted / CI — same type, never prompts
let coordinator = AppCoordinator(picker: NonInteractivePicker(assumeYes: true))
```

### Conforming Types

| Type | Module | Use |
|------|--------|-----|
| `SwiftPicker` | `SwiftPickerKit` | Real terminal interaction |
| `NonInteractivePicker` | `SwiftPickerKit` | Scripted runs; never prompts |
| `MockSwiftPicker` | `SwiftPickerTesting` | Tests; scripted responses and prompt capture |

---

## Struct: SwiftPicker

The concrete entry point conforming to `CommandLinePicker`.

```swift
public struct SwiftPicker {
    public init()
}
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init()` | Creates a picker with default terminal input handling |

### Conformances

`CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, `CommandLineTreeNavigation` (and therefore `CommandLinePicker`)

### Terminal Side Effects

- Registers SIGINT/SIGTERM signal handlers during picker display (cleaned up on exit)
- Each keypress triggers a full screen clear and redraw cycle
- If SIGINT arrives during a picker, the handler restores terminal state and calls `exit(130)`

### Usage Example

```swift
let picker = SwiftPicker()
let item = picker.singleSelection(prompt: "Choose:", items: ["A", "B", "C"])
let confirmed = picker.getPermission(prompt: "Continue? (y/n): ")
let name = picker.getInput(prompt: "Enter name: ")
```

---

## Best Practices

- **Depend on protocols, not `SwiftPicker`** — Use `CommandLinePicker` (or a narrower protocol like `CommandLineSelection`) as your dependency type. Instantiate `SwiftPicker()` only at the composition root.
- **Use `CommandLinePicker` for full access** — If your code needs input, permission, selection, and tree navigation, use the combined typealias as the dependency type.
- **Prefer non-throwing variants for optional flows** — `singleSelection` returns `nil` on cancel; use `requiredSingleSelection` only when cancellation is a true error.
- **`newScreen: false` still calls exit cleanup** — Even when `newScreen` is false (no alternative screen entered), `exitAlternativeScreen()` and `enableNormalInput()` are called on exit. This is safe but worth knowing.
- **`String` works directly** — `String` conforms to `DisplayablePickerItem` out of the box, so `["A", "B", "C"]` is valid for quick prototyping.
- **Multi-selection quit discards everything** — When the user presses quit in multi-selection mode, all toggled selections are lost and an empty array is returned. There is no "confirm partial" behavior.
- **Swap the picker, not the call sites** — To support a `--non-interactive` flag, keep depending on `CommandLinePicker` and choose `SwiftPicker()` or `NonInteractivePicker(assumeYes:)` at the composition root. No call site needs to branch on mode.
- **Name the flag when one exists** — Prefer `getRequiredInput(prompt:flagHint: "--name")` over the plain variant in CLI tools. The message tells the user how to avoid the prompt entirely, and reads correctly interactively too.
- **Guard empty multi-selections** — `multiSelection` returning `[]` is indistinguishable from a deliberate empty choice. Use `requiredMultiSelection(prompt:items:flagHint:)` whenever zero items should be an error.
