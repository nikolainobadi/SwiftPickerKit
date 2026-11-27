# Changelog

All notable changes to SwiftPickerKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `StyledPickerItem` lets items choose their row style through `displayStyle: PickerTextStyle?`. Inactive rows use the style, the active row keeps it and adds an underline, and rows in the unfocused tree column are dimmed. Items that don't conform are unchanged
- `PickerTextStyle` (color plus bold, dim, underline, with `.success`, `.warning`, `.failure`, `.muted`, `.standout`, and `.heading` presets) and `PickerColor` (16 named ANSI colors plus `.palette(UInt8)`)
- `PickerTheme` recolors markers, pointers, gray text, dividers, headers, breadcrumbs, and arrows; `PickerTheme.standard` matches the previous colors. Pass one through the new `SwiftPicker(interruptBehavior:assumeYes:permissionSubmitMode:theme:)`; existing initializers use `.standard`
- `SegmentedPickerItem` draws one row in several styles through `displaySegments: [PickerTextSegment]`, such as a red `failed` and a yellow `not fixed` in the same row. Segments are truncated across their combined width before styling, the active row underlines every segment, and unstyled segments fall back to the item's `displayStyle` or the theme's gray. Works in list and tree-navigation pickers
- `TreeNode.displayStyle` and `TreeNode(name:value:hasChildren:isSelectable:metadata:displayStyle:loadChildren:)`
- Pickers leave out colors when standard output isn't a terminal, `NO_COLOR` is set, or `TERM` is `dumb`, while keeping bold, dim, and underline

### Changed
- Rows in the unfocused tree-navigation column are drawn dimmed in their own color instead of a flat gray

### Fixed
- Truncation, centering, and wrapping measure visible width, so styled text is no longer cut early, cut inside an escape sequence, or drawn off-center; a cut styled line ends with a style reset
- The tree breadcrumb is truncated before it is colored, so a long path no longer leaks its color or leaves a partial escape sequence

## [0.15.1] - 2026-11-21

### Fixed
- `browseDirectories(..., selectionType: .onlyFolders)` and `FileSystemNode.loadChildren()` under `.onlyFolders` no longer list files; previously files appeared as rows that could not be selected. `.onlyFiles` and `.filesAndFolders` still list both files and folders

## [0.15.0] - 2026-11-11

### Added
- `SwiftPicker(interruptBehavior:assumeYes:permissionSubmitMode:)` accepts `PermissionSubmitMode.immediate` to answer permission prompts with `y`/`Y` or `n`/`N` without pressing Enter; other keys are ignored. Non-terminal input falls back to line-based answers, and existing initializers keep requiring Enter. When `assumeYes` is `true`, permission prompts remain automatically approved

## [0.14.0] - 2026-11-07

### Added
- `SwiftPicker(interruptBehavior:assumeYes:)` treats every permission prompt as approved when `assumeYes` is `true`: `getPermission` returns `true` without asking, so `requiredPermission` and its `flagHint:` overload never throw. Text input, secret input, selection, and tree navigation still prompt. Pass a CLI's `--yes` flag here so it also applies to interactive runs, not only `NonInteractivePicker(assumeYes:)`

## [0.13.1] - 2026-10-31

No user-facing changes.

## [0.13.0] - 2026-10-31

### Added
- `SwiftPicker.getSecretInput(prompt:)` reads passwords and tokens without echoing typed characters, restores terminal echo after completion or interruption, and accepts piped input
- `getRequiredSecretInput(prompt:)` throws `SwiftPickerError.inputRequired` for empty input or `PickerInterruptedError` when a `SwiftPicker` secret prompt is interrupted; both secret input methods also have unlabeled prompt overloads
- `MockSwiftPicker(secretInputResult:)`, `capturedSecretPrompts`, and `ScriptedPicker.make(secretInputs:)` support configuring secret responses and capturing secret prompts independently of ordinary text input
- `NonInteractivePicker` returns an empty string for secret input without prompting, so required secret input throws `SwiftPickerError.inputRequired`

### Changed
- **BREAKING**: `CommandLineInput` now requires `getSecretInput(prompt:) -> String`; implement this method in custom conformers

## [0.12.1] - 2026-10-20

### Changed
- `SwiftPickerTesting` now re-exports `SwiftPickerKit`, so files that import `SwiftPickerTesting` can use public `SwiftPickerKit` APIs without a separate `import SwiftPickerKit`

## [0.12.0] - 2026-10-17

### Added
- `SwiftPicker(interruptBehavior:)` with `PickerInterruptBehavior.finishAsCancelled` (the default) and `.waitForTermination` to control interrupted selection prompts when the host keeps running. Use `.waitForTermination` only when the host always terminates on interrupt; otherwise the prompt never returns
- `PickerInterruptedError` distinguishes Ctrl+C or SIGTERM from user cancellation in `SwiftPicker`'s `requiredSingleSelection` and `requiredTreeNavigation`, including their `flagHint:` overloads, and `requiredMultiSelection(flagHint:)`. Catch this error to stop the interrupted workflow when the host keeps running

### Fixed
- Selection prompts restore the terminal before forwarding SIGINT or SIGTERM to the host's signal handling, and restore the host's original handlers when the prompt closes; hosts without a handler now terminate by the received signal instead of always exiting with code 130
- Interrupted single selection, multi-selection, and tree navigation stop processing input when the host keeps running; with the default interrupt behavior, optional selections return `nil` or an empty array

## [0.11.0] - 2026-09-14

### Added
- `ScriptedPicker.make(...)` and `ScriptedPicker.silent()` in `SwiftPickerTesting` for building `MockSwiftPicker` instances with independent ordered response queues for multi-prompt tests; exhausted queues fall back to empty input, denied permission, or no selection

## [0.10.0] - 2026-08-15

### Added
- `NonInteractivePicker`, a `CommandLinePicker` that never prompts — every method returns immediately with a "nothing was provided" value, so `required*` calls throw instead of hanging in scripted, piped, or CI runs. Pass `assumeYes: true` to resolve permission prompts to `true`
- `flagHint:` overloads of `getRequiredInput`, `requiredPermission`, `requiredSingleSelection`, `requiredMultiSelection`, and `requiredTreeNavigation` that name the command line flag a caller can pass instead of answering the prompt
- `requiredMultiSelection(prompt:items:flagHint:)`, which treats an empty selection as a failure rather than silently continuing with zero items
- `PickerRequirementError` with `missingInput`, `missingSelection`, and `confirmationRequired` cases, describing the missing value and the flag that supplies it
- `Sendable` conformance on `MockSingleSelectionOutcome`, `MockMultiSelectionOutcome`, and `MockTreeSelectionOutcome`
- The SwiftPickerKit API-reference skill now ships in this repo at `Skills/SwiftPickerKit/`, installable from the `nn-swift-skills` marketplace and pinned to this release's tag. It previously lived in a separate repo, where it drifted out of date
- A `Skill docs` CI check that fails pull requests changing the public API without updating `Skills/`, waivable with the `skip-skill-check` label

### Changed
- Adopted the Swift 6 language mode (`swift-tools-version: 6.2`). **Requires Xcode 26 or later to build.**
- Annotated the process-global signal handler state and `FileSystemNode.showHiddenFiles` / `selectionType` as `nonisolated(unsafe)`; call sites are unchanged

## [0.9.0] - 2025-12-11

### Added
- Directory browsing API (`browseDirectories`) with configurable file/folder selection via `FileSystemNode.SelectionType`
- Inline documentation for core tree navigation types and protocols

### Changed
- Removed `newScreen` parameter from `treeNavigation` methods (alternate screen buffer now always used)
- `MockSwiftPicker` is now `open` instead of `final` to allow subclassing in testing scenarios

## [0.8.1] - 2025-12-09

### Added
- Scroll support for second column in two-column tree navigation layouts

### Fixed
- Scrolling issue where long lists in tree navigation weren't being displayed properly

## [0.8.0] - 2025-12-08

### Added
- Child selection support in `MockSwiftPicker` for testing tree navigation with nested items
- `selectedChildIndex` parameter to `MockTreeSelectionOutcome` for granular test control
- New `.child(parentIndex:childIndex:)` factory method for configuring nested tree selections in tests

## [0.7.0] - 2025-12-04

### Added
- Dual-column tree navigation with parent item display when navigating into folders
- Additional convenience methods for `CommandLineSelection` protocol
- Comprehensive inline documentation for core types and protocols
- `showPromptText` parameter to tree navigation for controlling prompt visibility

### Changed
- **BREAKING**: Tree navigation now requires `TreeNavigationRoot<Item>` wrapper instead of `[Item]` array
- **BREAKING**: Removed `allowSelectingFolders` parameter from tree navigation API (use `TreeNodePickerItem.isSelectable` instead)
- **BREAKING**: Removed `startInsideFirstRoot` parameter from tree navigation API (root-start logic now handled internally)
- **BREAKING**: `showSelectedItemText` moved from default parameter to required protocol parameter
- Improved tree navigation rendering for left/right arrow indicators
- Enhanced empty folder identification to display metadata correctly

### Fixed
- Tree navigation bug when navigating parent node items
- Column navigation issues in two-column layouts
- Right arrow navigation incorrectly enabled for empty tree items
- Left/right arrow rendering in tree navigation headers

## [0.6.0] - 2025-11-20

### Added
- `showSelectedItemText` parameter to `CommandLineSelection` methods to control whether selected item text is displayed in the header

### Changed
- Moved required protocol methods to convenience extensions for `CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, and `CommandLineTreeNavigation` for cleaner protocol definitions

### Fixed
- Empty folder identification during tree navigation now correctly displays metadata
