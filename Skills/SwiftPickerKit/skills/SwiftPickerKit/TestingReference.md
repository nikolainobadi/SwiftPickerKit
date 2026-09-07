# Testing Reference

Mock types from the `SwiftPickerTesting` module for testing code that depends on `CommandLinePicker`.

**Import:** `import SwiftPickerTesting`

## Choosing a Test Double

| Need | Use | Module |
|------|-----|--------|
| Scripted responses, prompt capture, assertions on what was asked | `MockSwiftPicker` | `SwiftPickerTesting` |
| The same, for a flow that asks several kinds of question in order | `ScriptedPicker` | `SwiftPickerTesting` |
| Every prompt to resolve to "nothing provided" so `required*` throws | `NonInteractivePicker` | `SwiftPickerKit` |

`NonInteractivePicker` is production code, not a test double — it ships in the main module for
scripted and CI runs. It's the right choice when a test only needs to prove that a flow fails
cleanly without input; reach for `MockSwiftPicker` whenever the test cares *which* prompts appeared
or needs to supply answers.

---

## Class: MockSwiftPicker

Open mock class conforming to `CommandLinePicker`. No terminal I/O. Captures prompts and returns preconfigured responses.

```swift
open class MockSwiftPicker {
    public init(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        treeNavigationResult: MockTreeNavigationResult = .init()
    )
}
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(inputResult:permissionResult:selectionResult:treeNavigationResult:)` | Configure mock responses for each interaction type |

### Captured Prompts

| Property | Type | Description |
|----------|------|-------------|
| `capturedPrompts` | `[String]` | All prompts passed to `getInput` |
| `capturedPermissionPrompts` | `[String]` | All prompts passed to `getPermission` |
| `capturedSingleSelectionPrompts` | `[String]` | All prompts passed to `singleSelection` |
| `capturedMultiSelectionPrompts` | `[String]` | All prompts passed to `multiSelection` |
| `capturedTreeNavigationPrompts` | `[String]` | All prompts passed to `treeNavigation` |

### Conformances

`CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, `CommandLineTreeNavigation` (and therefore `CommandLinePicker`)

### Behavioral Notes

- **Ignores layout, newScreen, showSelectedItemText** — All display parameters are ignored; only prompt and items matter
- **Tree navigation depth limit** — Resolves at most one level of children (root → child). Subclass `MockSwiftPicker` for deeper trees.
- **Multi-selection order** — Returns items in the order of `selectedIndices`, not item array order. Out-of-bounds indices are silently dropped.
- **Open for subclassing** — Override methods for custom test double behavior.

---

## Enum: ScriptedPicker

Static factories that build a `MockSwiftPicker` from ordered queues. Use it when a test scripts
more than one kind of prompt; reach for `MockSwiftPicker` directly when it scripts only one.

```swift
public enum ScriptedPicker {
    public static func make(
        permissions: [Bool] = [],
        singles: [MockSingleSelectionOutcome] = [],
        multis: [MockMultiSelectionOutcome] = [],
        inputs: [String] = [],
        treeNavigations: [MockTreeSelectionOutcome] = []
    ) -> MockSwiftPicker

    public static func silent() -> MockSwiftPicker
}
```

Name only the queues the flow under test exercises. The omission carries meaning: a call naming
`inputs` alone says the flow asks for text and nothing else.

### Fallbacks

Each queue falls back independently once drained. These are the `Mock*Result` defaults, restated
here because they are what makes a scripted flow terminate rather than repeat:

| Question | Method | Fallback |
|----------|--------|----------|
| Text input | `getInput` | `""` |
| Permission | `getPermission` | `false` |
| Single selection | `singleSelection` | `.none` (returns `nil`) |
| Multi selection | `multiSelection` | `.none` (returns `[]`) |
| Tree navigation | `treeNavigation` | `.none` (returns `nil`) |

### Behavioral Notes

- **Queues advance independently** — the third `getInput` takes the third element of `inputs`, no matter how many permission prompts came between
- **Exhaustion is not an error** — a flow that asks more questions than the script anticipated gets "no" and "nothing chosen", so a `while` loop asking permission terminates rather than spinning
- **`silent()` vs `NonInteractivePicker`** — both answer "nothing provided" to everything. Use `silent()` when the test asserts on `captured*Prompts`; use `NonInteractivePicker` when it only needs `required*` calls to throw
- **Ordered mode only** — every queue is `.ordered`. For prompt-keyed answers, construct `MockSwiftPicker` directly with a `.dictionary` `Mock*Result`

```swift
let picker = ScriptedPicker.make(
    permissions: [true],
    singles: [.index(1)],
    inputs: ["MyProject"]
)

let name = picker.getInput(prompt: "Project name:")   // "MyProject"
let confirmed = picker.getPermission(prompt: "Create?") // true
let again = picker.getPermission(prompt: "Another?")    // false (drained)
```

---

## Struct: MockInputResult

Configures text input responses.

```swift
public struct MockInputResult {
    public var type: MockInputType
    public var defaultValue: String

    public init(defaultValue: String = "", type: MockInputType = .ordered([]))
}
```

### Enum: MockInputType

| Case | Description |
|------|-------------|
| `ordered([String])` | Returns values sequentially; falls back to `defaultValue` when exhausted |
| `dictionary([String: String])` | Returns value keyed by exact prompt text; falls back to `defaultValue` on miss |

---

## Struct: MockPermissionResult

Configures yes/no permission responses.

```swift
public struct MockPermissionResult {
    public var type: MockPermissionType
    public var defaultValue: Bool

    public init(defaultValue: Bool = false, type: MockPermissionType = .ordered([]))
}
```

### Enum: MockPermissionType

| Case | Description |
|------|-------------|
| `ordered([Bool])` | Returns values sequentially; falls back to `defaultValue` when exhausted |
| `dictionary([String: Bool])` | Returns value keyed by exact prompt text; falls back to `defaultValue` on miss |

---

## Struct: MockSelectionResult

Configures single and multi-selection responses.

```swift
public struct MockSelectionResult {
    public var defaultSingle: MockSingleSelectionOutcome
    public var defaultMulti: MockMultiSelectionOutcome
    public var singleType: MockSingleSelectionType
    public var multiType: MockMultiSelectionType

    public init(
        defaultSingle: MockSingleSelectionOutcome = .none,
        defaultMulti: MockMultiSelectionOutcome = .none,
        singleType: MockSingleSelectionType = .ordered([]),
        multiType: MockMultiSelectionType = .ordered([])
    )
}
```

### Enum: MockSingleSelectionType

| Case | Description |
|------|-------------|
| `ordered([MockSingleSelectionOutcome])` | Sequential single-selection outcomes |
| `dictionary([String: MockSingleSelectionOutcome])` | Prompt-keyed outcomes |

### Enum: MockMultiSelectionType

| Case | Description |
|------|-------------|
| `ordered([MockMultiSelectionOutcome])` | Sequential multi-selection outcomes |
| `dictionary([String: MockMultiSelectionOutcome])` | Prompt-keyed outcomes |

### Struct: MockSingleSelectionOutcome

| Property | Type | Description |
|----------|------|-------------|
| `selectedIndex` | `Int?` | Index of the item to select; `nil` simulates cancellation |

| Factory | Description |
|---------|-------------|
| `.none` | No selection (cancelled) |
| `.index(_ index: Int)` | Select item at given index |

### Struct: MockMultiSelectionOutcome

| Property | Type | Description |
|----------|------|-------------|
| `selectedIndices` | `[Int]` | Indices of items to select |

| Factory | Description |
|---------|-------------|
| `.none` | Empty selection |
| `.indices(_ indices: [Int])` | Select items at given indices |

---

## Struct: MockTreeNavigationResult

Configures tree navigation responses.

```swift
public struct MockTreeNavigationResult {
    public var defaultOutcome: MockTreeSelectionOutcome
    public var type: MockTreeSelectionType

    public init(
        defaultOutcome: MockTreeSelectionOutcome = .none,
        type: MockTreeSelectionType = .ordered([])
    )
}
```

### Enum: MockTreeSelectionType

| Case | Description |
|------|-------------|
| `ordered([MockTreeSelectionOutcome])` | Sequential tree selection outcomes |
| `dictionary([String: MockTreeSelectionOutcome])` | Prompt-keyed outcomes |

### Struct: MockTreeSelectionOutcome

| Property | Type | Description |
|----------|------|-------------|
| `selectedRootIndex` | `Int?` | Index in root children; `nil` simulates cancellation |
| `selectedChildIndex` | `Int?` | Optional child index (one level deep) |

| Factory | Description |
|---------|-------------|
| `.none` | No selection (cancelled) |
| `.index(_ index: Int)` | Select root-level item at index |
| `.child(parentIndex:childIndex:)` | Select a child item one level deep |

---

## Complete Example

```swift
import Testing
@testable import YourApp
import SwiftPickerTesting

struct FeaturePickerTests {
    @Test("Starts with no captured prompts")
    func startingValues() {
        let mock = makeSUT()

        #expect(mock.capturedPrompts.isEmpty)
        #expect(mock.capturedSingleSelectionPrompts.isEmpty)
        #expect(mock.capturedPermissionPrompts.isEmpty)
    }

    @Test("Returns preconfigured single selection by index")
    func singleSelectionByIndex() {
        let mock = makeSUT(
            selectionResult: MockSelectionResult(
                singleType: .ordered([.index(1)])
            )
        )

        let items = ["Alpha", "Beta", "Gamma"]
        let result = mock.singleSelection(
            prompt: "Pick one:",
            items: items,
            layout: .singleColumn,
            newScreen: false,
            showSelectedItemText: false
        )

        #expect(result == "Beta")
        #expect(mock.capturedSingleSelectionPrompts == ["Pick one:"])
    }

    @Test("Returns permission based on prompt dictionary")
    func permissionByPrompt() {
        let mock = makeSUT(
            permissionResult: MockPermissionResult(
                type: .dictionary(["Delete?": true, "Format?": false])
            )
        )

        #expect(mock.getPermission(prompt: "Delete?") == true)
        #expect(mock.getPermission(prompt: "Format?") == false)
    }

    @Test("Returns tree navigation child selection")
    func treeChildSelection() {
        let mock = makeSUT(
            treeNavigationResult: MockTreeNavigationResult(
                type: .ordered([.child(parentIndex: 0, childIndex: 1)])
            )
        )

        let children = [
            TreeNode(name: "Child A", value: "a"),
            TreeNode(name: "Child B", value: "b")
        ]
        let root = TreeNavigationRoot(
            displayName: "Root",
            children: [
                TreeNode(name: "Parent", value: "p", hasChildren: true) { children }
            ]
        )

        let result = mock.treeNavigation(prompt: "Browse:", root: root)

        #expect(result?.value == "b")
    }
}

// MARK: - SUT
private extension FeaturePickerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        treeNavigationResult: MockTreeNavigationResult = .init()
    ) -> MockSwiftPicker {
        return MockSwiftPicker(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult,
            treeNavigationResult: treeNavigationResult
        )
    }
}
```

## Common Patterns

### Pattern: Sequential Responses

```swift
// Mock returns different values for successive calls
let mock = MockSwiftPicker(
    inputResult: MockInputResult(type: .ordered(["Alice", "Bob", "Charlie"]))
)

let first = mock.getInput(prompt: "Name:")   // "Alice"
let second = mock.getInput(prompt: "Name:")  // "Bob"
let third = mock.getInput(prompt: "Name:")   // "Charlie"
let fourth = mock.getInput(prompt: "Name:")  // "" (defaultValue, ordered exhausted)
```

### Pattern: Prompt-Keyed Responses

```swift
// Mock returns values based on the prompt text (exact match, case-sensitive)
let mock = MockSwiftPicker(
    permissionResult: MockPermissionResult(
        type: .dictionary(["Save?": true, "Overwrite?": false])
    )
)

mock.getPermission(prompt: "Save?")      // true
mock.getPermission(prompt: "Overwrite?") // false
mock.getPermission(prompt: "Unknown?")   // false (defaultValue)
```

---

## Best Practices

- **Prefer `ScriptedPicker` for multi-prompt flows** — `ScriptedPicker.make` takes the queues directly instead of assembling `Mock*Result` values, and you name only the ones the flow exercises. Use `ScriptedPicker.silent()` for a picker that should never be asked anything.
- **Inject via `CommandLinePicker` protocol** — Your production code should depend on `CommandLinePicker` (or a narrower protocol). In tests, pass `MockSwiftPicker`; in production, pass `SwiftPicker()`.
- **Use `.ordered` for sequential tests, `.dictionary` for prompt-keyed** — Ordered mode is simpler for tests with a known call sequence. Dictionary mode is better when multiple prompts occur in unpredictable order.
- **Dictionary matching is case-sensitive** — `"Prompt"` and `"prompt"` are different keys. Match the exact prompt string your production code passes.
- **Ordered responses are consumed destructively** — Each call dequeues the next value. Once exhausted, `defaultValue`/`defaultOutcome` is returned for all subsequent calls indefinitely.
- **Tree navigation resolves one level deep** — `MockSwiftPicker.treeNavigation` only supports root and one child level. For deeper trees, subclass `MockSwiftPicker` (it is `open`).
- **Verify prompts for correctness** — Use `capturedPrompts`, `capturedSingleSelectionPrompts`, etc. to assert that your code passes the expected prompt strings.
