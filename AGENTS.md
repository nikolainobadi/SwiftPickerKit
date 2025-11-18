# Repository Guidelines

## Project Structure & Module Organization
`Sources/SwiftPickerKit` hosts the library, split into `Core`, `Picker`, `Selection`, `Rendering`, and `Input`; add new types to the matching folder so imports stay predictable. `Sources/SwiftPickerTesting` provides consumer/test mocks, while `Tests/SwiftPickerKitTests` mirrors the runtime namespace for verification. Use `SwiftPickerDemo/` to exercise new flows before shipping.

## Build, Test, and Development Commands
- `swift build` — compiles the package against Swift 5.9 and refreshes the pinned `ANSITerminalModified` dependency.
- `swift test` — runs the Swift Testing suite in `Tests/SwiftPickerKitTests`.
- `swift test --enable-code-coverage` — produces coverage data for CI/PR checklists.
- `swift run SwiftPickerDemo` (inside `SwiftPickerDemo/`) — launches the interactive picker showcase; pass `--help` for scenario options.
Commit regenerated `Package.resolved` only when the dependency graph truly changes.

## Coding Style & Naming Conventions
Use Swift 5.9 features, four-space indentation, and `// MARK:` organization as in `SwiftPicker.swift`. Type names are nouns (`SelectionState`, `PickerLayout`), protocols end in `Input`/`Renderer`, behaviors add suffixes like `SingleBehavior`, and functions read as imperative verbs (`runSelection`). Mirror filenames and types for renderers or states (`TwoColumnDynamicDetailState.swift`) and prefer protocol extensions over giant classes.

## Testing Guidelines
Tests leverage the Swift `Testing` module (`@Test func ...`) and should mirror the production namespace (`Selection` tests under `Tests/SwiftPickerKitTests/Selection`). Prefer `SwiftPickerTesting` mocks over shell-based IO, and name methods after behaviors (`testMultiSelectionHighlightsActiveRow`). Target coverage around selection flows and renderer trimming; capture reports via `swift test --enable-code-coverage` when shipping user-visible changes.

## Commit & Pull Request Guidelines
Commits are short and imperative (“enable tree navigation”, “refactor dynamic detail”) and should stay under ~70 characters; squash fixups before review. Each PR needs a scenario summary, linked issue, UX impact statement, and validation notes (commands, demo prompts, screenshots when terminal output changes). Paste `swift test` (and demo) results so reviewers can reproduce quickly.

## Terminal & Configuration Tips
The picker relies on `ANSITerminal` escape sequences; always leave the screen clean by invoking `pickerInput.exitAlternativeScreen()` after experiments. Avoid blocking calls that lock cursor handling. When testing remotely, disable multiplexers that hijack arrow keys or export `TERM=xterm-256color` to keep color rendering consistent.

## Public API Expectations
- Clear, well-documented public interfaces
- Semantic versioning for breaking changes
- Comprehensive examples in documentation

## Package Testing
- Behavior-driven unit tests (Swift Testing preferred)
- Use `makeSUT` pattern for test organization
- Track memory leaks with `trackForMemoryLeaks`
- Type-safe assertions (`#expect`, `#require`)
- Use `waitUntil` for async/reactive testing

## Imports
@~/.config/sharedAIConfig/guidelines/shared-formatting.md
@~/.config/sharedAIConfig/guidelines/iOS_Unit_Testing_Guide.md
