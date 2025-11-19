# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Required Guidelines (MUST READ)
@~/.claude/guidelines/shared-formatting-claude.md
@~/.claude/guidelines/ios_unit_testing_claude_instructions.md

**CRITICAL: These are not optional suggestions - they are mandatory requirements.**

### When to Read Each Guideline
- **shared-formatting.md** — MUST read BEFORE writing or editing ANY Swift code in this project
- **iOS_Unit_Testing_Guide.md** — MUST read BEFORE writing, modifying, or reviewing ANY test code

**Compliance Rule:** If you are asked to write tests and have not yet read iOS_Unit_Testing_Guide.md in this conversation, you MUST read it first before writing a single test. Do not rely on general knowledge - read the actual guideline file.

## Project Overview
SwiftPickerKit is a Swift Package Manager library for building interactive terminal-based pickers with support for single-selection, multi-selection, two-column layouts, and hierarchical tree navigation. The package targets macOS 12+ and depends on ANSITerminalModified for terminal control.

## Build & Test Commands
- `swift build` — compile the package and resolve dependencies
- `swift test` — run Swift Testing suite in Tests/SwiftPickerKitTests
- `swift test --enable-code-coverage` — generate coverage reports
- `cd SwiftPickerDemo && swift run SwiftPickerDemo [subcommand]` — run interactive demo
  - Subcommands: `single`, `multi`, `dynamic`, `choose`, `browse`
  - Use `--help` on any subcommand for flags (e.g., `-s` for small list, `-d` for detail column)

## Architecture

### Core Design Pattern
SwiftPickerKit uses a **State-Behavior-Renderer** architecture where each picker mode combines three components:

1. **State** (`BaseSelectionState` protocol) — tracks current selection, active index, options, and UI text
2. **Behavior** (`SelectionBehavior` protocol) — handles arrow keys and special characters (enter/space/quit/backspace)
3. **Renderer** (`ContentRenderer` protocol) — draws the visible content to the terminal

The `SelectionHandler` orchestrates these three components in a render loop, managing signal handling, scrolling, header/footer rendering, and user input capture.

### Module Organization
- **Core/** — `SwiftPicker` entry point, protocols (`DisplayablePickerItem`, `TextInput`, `PickerInput`), error types, signal handling
- **Picker/** — public API extensions on `SwiftPicker` for each picker mode (single/multi/tree/text/permission)
- **Selection/** — internal state/behavior/renderer implementations organized by mode:
  - **Behavior/** — `*Behavior` classes implementing `SelectionBehavior`
  - **State/** — `*State` classes conforming to `BaseSelectionState`
  - **Renderer/** — `*Renderer` classes conforming to `ContentRenderer`
  - **Models/** — `PickerLayout`, `TreeNode`, `FileSystemNode`, `TreeNodePickerItem`
  - **Engine/** — `SelectionHandler` (the input loop coordinator)
- **Rendering/** — shared rendering utilities (header, footer, scroll arrows, text formatting, padding, dividers)
- **Input/** — default implementations (`DefaultPickerInput`, `DefaultTextInput`) wrapping ANSITerminal

### Key Abstractions

#### DisplayablePickerItem
All items shown in pickers must conform to this protocol:
```swift
protocol DisplayablePickerItem {
    var displayName: String { get }
    var description: String { get }
}
```

#### PickerLayout
Public API uses `PickerLayout<Item>` enum to select rendering mode:
- `.singleColumn` — basic vertical list
- `.twoColumnStatic(detailText: String)` — left column items, fixed right detail panel
- `.twoColumnDynamic(detailForItem: (Item) -> String)` — left column items, right detail updates per selection

#### Tree Navigation
For hierarchical browsing, items conform to `TreeNodePickerItem`:
```swift
protocol TreeNodePickerItem: DisplayablePickerItem {
    var hasChildren: Bool { get }
    func fetchChildren() -> [Self]
}
```
The `TreeNavigationBehavior` intercepts left/right arrows to descend/ascend the tree. `FileSystemNode` is a concrete implementation for filesystem browsing.

### Rendering Flow
1. `SelectionHandler.renderFrame()` calculates screen dimensions and scroll bounds
2. `PickerHeaderRenderer` renders prompt, top-line text, and selected item detail (if any)
3. `ContentRenderer` (e.g., `SingleColumnRenderer`, `TwoColumnDynamicDetailRenderer`) draws visible items
4. `PickerFooterRenderer` renders instruction text at the bottom
5. `ScrollRenderer` adds up/down arrows when content exceeds visible area

### Adding New Picker Modes
1. Define a new `*State` conforming to `BaseSelectionState` (e.g., in Selection/State/)
2. Implement a `*Behavior` conforming to `SelectionBehavior` (e.g., in Selection/Behavior/)
3. Implement a `*Renderer` conforming to `ContentRenderer` (e.g., in Selection/Renderer/)
4. Add a public API extension in Picker/ that creates a `SelectionHandler` with your three components
5. Mirror the pattern in `SwiftPicker+TreeNavigation.swift` or the layout switch in `SwiftPicker.swift:197`

## Coding Conventions
**MANDATORY: Follow all formatting rules in @shared-formatting.md when writing or editing Swift code.**

Project-specific conventions:
- Use Swift 5.9+ features, four-space indentation, no tabs
- Organize files with `// MARK:` sections (see SwiftPicker.swift or SelectionHandler.swift)
- Type names are nouns (`SelectionState`, `PickerLayout`), protocols end in `Input`/`Renderer`, behaviors suffix with `Behavior`
- Mirror filenames to types: `TwoColumnDynamicDetailState.swift` contains `TwoColumnDynamicDetailState`
- Author: always use **Nikolai Nobadi** in Swift file headers (never Claude or Claude Code)

## Testing
**MANDATORY: Read @iOS_Unit_Testing_Guide.md BEFORE writing any tests. All patterns, conventions, and rules defined in that guide MUST be followed exactly.**

Quick reference (see guide for full details):
- Swift Testing framework (`@Test func ...`)
- Tests mirror production structure (e.g., `Tests/SwiftPickerKitTests/Selection/`)
- Use `SwiftPickerTesting.MockSwiftPicker` for testing without terminal I/O
- Follow behavior-driven test naming from the guide
- Use `makeSUT` pattern (memory leak tracking NOT required for this project)
- Target coverage on selection flows and renderer trimming

## Terminal & ANSITerminal
- All terminal I/O goes through `PickerInput` protocol (implemented by `DefaultPickerInput`)
- Always call `pickerInput.exitAlternativeScreen()` and `enableNormalInput()` after picker exits
- `SignalHandler` traps SIGINT/SIGTERM to clean up terminal state on Ctrl+C
- Avoid blocking calls that prevent cursor handling or arrow key reads

## Git & Commits
- Short imperative messages (~70 chars): "enable tree navigation", "refactor dynamic detail"
- Squash fixup commits before review
- Only commit `Package.resolved` when dependency graph changes

## Public API Expectations
- Clear, well-documented public interfaces
- Semantic versioning for breaking changes
- Comprehensive examples in documentation

## Package Testing
**See @iOS_Unit_Testing_Guide.md for comprehensive testing patterns - this is a summary only:**

- Behavior-driven unit tests (Swift Testing preferred)
- Use `makeSUT` pattern for test organization
- Memory leak tracking NOT required for this project
- Type-safe assertions (`#expect`, `#require`)
- Use `waitUntil` for async/reactive testing
