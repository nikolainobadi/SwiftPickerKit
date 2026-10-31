# CLAUDE.md

Guidance for Claude Code when working in this repository. See README.md for the public API and usage examples — don't duplicate it here.

## Overview
Swift Package Manager library for interactive terminal pickers: single/multi selection, two-column layouts, tree navigation, and file system browsing. macOS 13+, swift-tools 6.2 (Swift 6 language mode), depends on ANSITerminalModified.

Two products: `SwiftPickerKit` (the library) and `SwiftPickerTesting` (mocks for consumers). `SwiftPickerTesting` re-exports `SwiftPickerKit`, so importing it also exposes the library's public APIs.

## Skill Documentation

`Skills/SwiftPickerKit/` holds the published API-reference skill. It lives here — not in a
separate skills repo — so the API and its documentation change in the same PR. It previously
lived elsewhere and drifted out of date for months.

- **Any PR changing the public API must update `Skills/`.**
- **`Skills/SwiftPickerKit/.claude-plugin/plugin.json` deliberately has no `version` field.**
  Do not reintroduce one — the installer keys its cache by commit sha, and a hand-maintained
  version number is exactly the stale-number problem this layout removes.
- **SwiftPM ignores `Skills/`** — it is not a target and must not become one.

### Releasing

The skill is consumed through the `nn-swift-skills` marketplace, pinned to a **tag** rather
than tracking `main`. Tag this repo with no `v` prefix and push the tag. Consumers stay on the
previous tag's docs until the `ref` in `nn-swift-skills/.claude-plugin/marketplace.json` is updated.
This repository has no workflow to automate that marketplace update.

## Build & Test
- `swift build` — compile and resolve dependencies
- `swift test` — run the Swift Testing suite in `Tests/SwiftPickerKitTests`
- `swift test --enable-code-coverage` — coverage report
- `cd SwiftPickerDemo && swift run SwiftPickerDemo <subcommand>` — interactive demo
  - Subcommands: `single`, `multi`, `dynamic`, `choose`, `browse`, `secret` (use `--help` for flags)

## Architecture

Each picker mode is assembled from three pieces, wired together by `SelectionHandler` (`Selection/Engine/`), which owns the render loop, scrolling, signal handling, and input capture:

1. **State** — conforms to `BaseSelectionState` (`Selection/State/`); tracks options, active index, selection, UI text
2. **Behavior** — conforms to `SelectionBehavior` (`Selection/Behavior/`); handles arrow keys and enter/space/quit/backspace
3. **Renderer** — conforms to `ContentRenderer` (`Rendering/Columns/`); draws the visible content

`ContentRenderer` and `SelectionBehavior` are both declared in `SelectionHandler.swift`.

### Directory map
- `Core/` — public protocols (`CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, `CommandLineTreeNavigation`, and the `CommandLinePicker` typealias combining them), `DisplayablePickerItem`, `SwiftPickerError`, `SignalHandler`
- `Picker/` — the `SwiftPicker` struct plus one `SwiftPicker+CommandLine*.swift` extension per protocol. `TextInput` and `PickerInput` are declared in `SwiftPicker.swift`
- `Input/` — `DefaultPickerInput` wraps ANSITerminal; `DefaultTextInput` handles line prompts and uses `HiddenLineReader` with `StandardInputEcho` for secret input
- `Selection/` — `State/`, `Behavior/`, `Engine/`, and `Models/` (`PickerLayout`, `TreeNode`, `TreeNodePickerItem`, `FileSystemNode`, `TreeNavigationRoot`)
- `Rendering/` — `Columns/` (the content renderers), `HeaderFooter/`, `Scroll/`, `Common/`

### Key types
- `DisplayablePickerItem` — everything shown in a picker conforms to it (`displayName`, `description`)
- `PickerLayout<Item>` — chooses the renderer: `.singleColumn`, `.twoColumnStatic(detailText:)`, `.twoColumnDynamic(detailForItem:)`
- `TreeNodePickerItem` — adds `hasChildren` / `fetchChildren()`; `TreeNavigationBehavior` maps left/right arrows to ascend/descend. `FileSystemNode` is the filesystem implementation, and `browseDirectories` wraps it with a `SelectionType` of `.onlyFiles` / `.onlyFolders` / `.filesAndFolders`

### Adding a picker mode
Add a State, a Behavior, and a Renderer in the directories above, then construct a `SelectionHandler(state:pickerInput:behavior:renderer:waitForTermination:)` from a public extension in `Picker/`. Forward the picker's `waitForTermination` closure; follow `SwiftPicker+CommandLineSelection.swift` for the wiring.

## Terminal
- Selection terminal I/O goes through `PickerInput`; only `Input/DefaultPickerInput` talks to ANSITerminal for I/O. Renderers may import ANSITerminal for text styling only
- Secret input goes through `TextInput.getSecretInput(_:)`. `HiddenLineReader` installs signal cleanup before disabling echo; `StandardInputEcho` restores the saved terminal settings on completion or interruption and leaves non-terminal input unchanged. `TerminalEcho.restore()` must remain async-signal-safe
- Always `exitAlternativeScreen()` and `enableNormalInput()` on every exit path, including throws
- `SignalHandler` saves the host's SIGINT/SIGTERM handlers, restores terminal state before forwarding signals according to the saved disposition, and restores those handlers when the picker finishes
- `SwiftPicker()` defaults to `PickerInterruptBehavior.finishAsCancelled`: if the host keeps running after an interrupt, optional selections return `nil` or an empty array, while required selections on `SwiftPicker` throw `PickerInterruptedError`. Wrapping conformers retain their usual cancellation errors
- Interrupted secret prompts on `SwiftPicker` return `""`; `getRequiredSecretInput(prompt:)` throws `PickerInterruptedError` when the host keeps running. Empty required secrets otherwise throw `SwiftPickerError.inputRequired`. Secret prompts also honor `interruptBehavior`
- `.waitForTermination` restores the terminal and blocks until the host ends the process; use it only for hosts that terminate on every interrupt
- Avoid blocking calls that stall cursor handling or arrow key reads

## Conventions
- Four-space indentation, no tabs; `// MARK:` sections (see `SelectionHandler.swift`)
- Filenames mirror their type: `TwoColumnDynamicDetailState.swift` holds `TwoColumnDynamicDetailState`
- Naming: types are nouns, protocols end in `Input`/`Renderer`, behaviors end in `Behavior`
- File headers always use **Nikolai Nobadi** as author — never Claude
- Commits: short imperative, ~70 chars ("enable tree navigation"). Only commit `Package.resolved` when the dependency graph changes
- Semantic versioning; public API changes need doc comments and a CHANGELOG entry

## Testing
- Swift Testing (`@Test func ...`), tests mirror production structure under `Tests/SwiftPickerKitTests/`
- Use the `makeSUT` pattern; memory leak tracking is NOT required in this project
- Suites that run selection input loops, read secrets through `MockTextInput`, or touch signal state use `@Suite(.signalState)` from `Shared/SignalStateTrait.swift` to share a process-wide lock; `.serialized` alone only orders tests within one suite
- Signal-response tests call `SignalHandler.handle(signal:info:context:)` directly and preserve/restore host handlers; real signals can stop an attached debugger. Inject `waitForTermination: nil` in ordinary `SwiftPicker` test setup, or a recording closure when testing the wait behavior
- `SwiftPickerTesting.MockSwiftPicker` is `open` — subclass it to test consumers without terminal I/O. Configure secret answers with `secretInputResult`; secret prompts are recorded in `capturedSecretPrompts`, separately from `capturedPrompts`
- Prefer `ScriptedPicker.make` for flows that need ordered answers across multiple prompt kinds. The `secretInputs` queue is separate from `inputs`. Each queue advances independently and falls back to `""`, `false`, or no selection when exhausted; use `ScriptedPicker.silent()` when only prompt capture or empty fallbacks are needed
- `Shared/SignalTestHelpers.swift` provides `withPreservedSignalHandlers` and `installIgnoringHostHandler(for:)` for signal tests inside `.signalState` suites
- Behavior-driven test names; prioritize coverage on selection flows and renderer trimming
