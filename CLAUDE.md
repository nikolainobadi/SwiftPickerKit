# CLAUDE.md

Guidance for Claude Code when working in this repository. See README.md for the public API and usage examples — don't duplicate it here.

## Overview
Swift Package Manager library for interactive terminal pickers: single/multi selection, two-column layouts, tree navigation, and file system browsing. macOS 13+, swift-tools 6.2 (Swift 6 language mode), depends on ANSITerminalModified.

Two products: `SwiftPickerKit` (the library) and `SwiftPickerTesting` (mocks for consumers).

## Build & Test
- `swift build` — compile and resolve dependencies
- `swift test` — run the Swift Testing suite in `Tests/SwiftPickerKitTests`
- `swift test --enable-code-coverage` — coverage report
- `cd SwiftPickerDemo && swift run SwiftPickerDemo <subcommand>` — interactive demo
  - Subcommands: `single`, `multi`, `dynamic`, `choose`, `browse` (use `--help` for flags)

## Architecture

Each picker mode is assembled from three pieces, wired together by `SelectionHandler` (`Selection/Engine/`), which owns the render loop, scrolling, signal handling, and input capture:

1. **State** — conforms to `BaseSelectionState` (`Selection/State/`); tracks options, active index, selection, UI text
2. **Behavior** — conforms to `SelectionBehavior` (`Selection/Behavior/`); handles arrow keys and enter/space/quit/backspace
3. **Renderer** — conforms to `ContentRenderer` (`Rendering/Columns/`); draws the visible content

`ContentRenderer` and `SelectionBehavior` are both declared in `SelectionHandler.swift`.

### Directory map
- `Core/` — public protocols (`CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, `CommandLineTreeNavigation`, and the `CommandLinePicker` typealias combining them), `DisplayablePickerItem`, `SwiftPickerError`, `SignalHandler`
- `Picker/` — the `SwiftPicker` struct plus one `SwiftPicker+CommandLine*.swift` extension per protocol. `TextInput` and `PickerInput` are declared in `SwiftPicker.swift`
- `Input/` — `DefaultTextInput`, `DefaultPickerInput` (the ANSITerminal wrappers)
- `Selection/` — `State/`, `Behavior/`, `Engine/`, and `Models/` (`PickerLayout`, `TreeNode`, `TreeNodePickerItem`, `FileSystemNode`, `TreeNavigationRoot`)
- `Rendering/` — `Columns/` (the content renderers), `HeaderFooter/`, `Scroll/`, `Common/`

### Key types
- `DisplayablePickerItem` — everything shown in a picker conforms to it (`displayName`, `description`)
- `PickerLayout<Item>` — chooses the renderer: `.singleColumn`, `.twoColumnStatic(detailText:)`, `.twoColumnDynamic(detailForItem:)`
- `TreeNodePickerItem` — adds `hasChildren` / `fetchChildren()`; `TreeNavigationBehavior` maps left/right arrows to ascend/descend. `FileSystemNode` is the filesystem implementation, and `browseDirectories` wraps it with a `SelectionType` of `.onlyFiles` / `.onlyFolders` / `.filesAndFolders`

### Adding a picker mode
Add a State, a Behavior, and a Renderer in the directories above, then construct a `SelectionHandler(state:pickerInput:behavior:renderer:)` from a public extension in `Picker/`. Follow `SwiftPicker+CommandLineSelection.swift` for the wiring.

## Terminal
- All terminal I/O goes through `PickerInput`; only `Input/DefaultPickerInput` talks to ANSITerminal for I/O. Renderers may import ANSITerminal for text styling only
- Always `exitAlternativeScreen()` and `enableNormalInput()` on every exit path, including throws
- `SignalHandler` traps SIGINT/SIGTERM to restore terminal state on Ctrl+C
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
- `SwiftPickerTesting.MockSwiftPicker` is `open` — subclass it to test consumers without terminal I/O
- Behavior-driven test names; prioritize coverage on selection flows and renderer trimming
