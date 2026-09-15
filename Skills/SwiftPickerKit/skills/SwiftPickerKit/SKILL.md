---
name: SwiftPickerKit
description: SwiftPickerKit Swift API reference for terminal-based interactive pickers with single/multi-selection, two-column layouts, tree navigation, and file system browsing. USE WHEN writing code that imports SwiftPickerKit, implementing terminal pickers, configuring picker layouts, adding tree navigation, browsing directories, testing with MockSwiftPicker or ScriptedPicker.
user-invocable: true
---

# SwiftPickerKit

Interactive terminal-based picker library for macOS with single-selection, multi-selection, two-column layouts, hierarchical tree navigation, and file system browsing.

**Dependency:** `https://github.com/nikolainobadi/SwiftPickerKit.git`
**Platforms:** macOS 13+ | **Swift tools:** 6.2 (Swift 6 language mode, requires Xcode 26+)

> This skill lives in the SwiftPickerKit repo under `Skills/SwiftPickerKit/`. Any PR changing the
> package's public API must update it in the same change.

## Context Files

| File | Purpose | Load When |
|------|---------|-----------|
| `PickerApi.md` | Core picker protocols, SwiftPicker entry point, layouts, errors | Writing picker selection code, configuring layouts, handling input/permissions |
| `TreeNavigationApi.md` | Tree navigation protocol, TreeNode, FileSystemNode, directory browsing | Implementing hierarchical navigation, file browsing, custom tree items |
| `TestingReference.md` | MockSwiftPicker, ScriptedPicker, and all mock result types | Writing tests for code that depends on CommandLinePicker |

## Quick Reference

### Production
- **Entry point:** `SwiftPicker()` — conforms to `CommandLinePicker` (typealias of all four protocols)
- **Scripted/CI:** `NonInteractivePicker(assumeYes:)` — same protocols, never prompts; every primitive returns its "nothing provided" value so the `required*` variants throw instead of hanging
- **Depend on protocols:** Use `CommandLinePicker`, `CommandLineSelection`, `CommandLineInput`, `CommandLinePermission`, or `CommandLineTreeNavigation` as dependency types
- **Layouts:** `.singleColumn`, `.twoColumnStatic(detailText:)`, `.twoColumnDynamic(detailForItem:)`
- **Custom items:** Conform to `DisplayablePickerItem` (just `displayName: String`)
- **Tree items:** Conform to `TreeNodePickerItem` for hierarchical navigation; use `FileSystemNode` for filesystem browsing
- **Named flags:** `flagHint:` overloads of the `required*` methods report which CLI flag supplies a value instead of prompting for it
- **Errors:** `SwiftPickerError.selectionCancelled` (user quit), `.inputRequired` (empty text input); `PickerRequirementError` from the `flagHint:` overloads

### Testing
- **`MockSwiftPicker`** — Open class conforming to `CommandLinePicker`; no terminal I/O
- **`ScriptedPicker.make(...)`** — Builds a `MockSwiftPicker` from independent ordered queues for multi-prompt flows
- **`ScriptedPicker.silent()`** — Uses empty queues and fallback responses while still capturing prompts
- **Response modes:** `.ordered([...])` for sequential responses, `.dictionary([prompt: value])` for prompt-keyed
- **Prompt capture:** `capturedPrompts`, `capturedSingleSelectionPrompts`, `capturedMultiSelectionPrompts`, `capturedTreeNavigationPrompts`

## Examples

- "Add a single-selection picker to this CLI command" -> Loads `PickerApi.md`
- "Let the user browse directories and select a file" -> Loads `TreeNavigationApi.md`
- "Write tests for the feature that uses SwiftPicker" -> Loads `TestingReference.md`
