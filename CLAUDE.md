# CLAUDE.md

Guidance for Claude Code when working in this repository. See README.md for the public API and usage examples — don't duplicate it here.

## Overview
Swift Package Manager library for interactive terminal pickers: single/multi selection, two-column layouts, tree navigation, and file system browsing. macOS 13+, swift-tools 6.2 (Swift 6 language mode), depends on ANSITerminalModified.

Two products: `SwiftPickerKit` (the library) and `SwiftPickerTesting` (mocks for consumers).

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
than tracking `main`. A release is therefore two steps in two repos — but the second is now
automated:

1. Tag this repo (no `v` prefix — matches the last four tags) and push the tag.
2. `.github/workflows/skill-ref-bump.yml` fires on that push, rewrites `ref` in
   `nn-swift-skills/.claude-plugin/marketplace.json`, and opens a PR there. **Merge it.**

Until that PR merges, consumers stay on the previous tag's docs. Nothing breaks and nothing warns —
they just silently keep reading the old reference, which is why step 2 is automated rather than
written on a checklist.

The workflow authenticates with the repo secret **`MARKETPLACE_TOKEN`**: a fine-grained PAT named
`nn-swift-skills-ref-bump`, scoped to `nn-swift-skills` only (Contents + Pull requests, read and
write), **expiring 2027-08-15**. It is **shared with every other package repo** publishing to that
marketplace, so rotating it means re-setting the secret in each of them, not just here.

When it expires the workflow fails loudly on tag push — a red X, not silence. Treat that as "rotate
the shared token", not "this repo's workflow is broken."

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
