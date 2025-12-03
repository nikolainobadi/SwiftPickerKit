# SwiftPickerDemo

A command-line demo application showcasing all features of [SwiftPickerKit](../README.md). This executable provides interactive examples of single-selection, multi-selection, two-column layouts, dynamic detail panels, and tree navigation.

## Overview

SwiftPickerDemo is built with [Swift ArgumentParser](https://github.com/apple/swift-argument-parser) and demonstrates how to use SwiftPickerKit in real-world CLI applications. Each subcommand exercises different picker modes and layout options.

## Requirements

- macOS 14.0+
- Swift 5.9+
- SwiftPickerKit (local package dependency)

## Installation

From the SwiftPickerDemo directory:

```bash
swift build
```

## Usage

### Basic Command Structure

```bash
swift run SwiftPickerDemo <subcommand> [options]
```

Run with `--help` to see all available subcommands and options:

```bash
swift run SwiftPickerDemo --help
```

### Available Subcommands

#### `single` — Single-Selection Picker

Test single-selection with various layouts.

```bash
swift run SwiftPickerDemo single [--required] [--small] [--detail]
```

**Options:**
- `-r, --required` — Require a selection (throws if none is made)
- `-s, --small` — Use a smaller non-scrolling list
- `-d, --detail` — Show static detail column

**Examples:**
```bash
# Basic single selection
swift run SwiftPickerDemo single

# With static detail panel
swift run SwiftPickerDemo single --detail

# Required selection with small list
swift run SwiftPickerDemo single --required --small
```

#### `multi` — Multi-Selection Picker

Test multi-selection mode (checkbox-style).

```bash
swift run SwiftPickerDemo multi [--small] [--detail]
```

**Options:**
- `-s, --small` — Use a smaller list
- `-d, --detail` — Show static detail column

**Examples:**
```bash
# Basic multi-selection
swift run SwiftPickerDemo multi

# With static detail panel
swift run SwiftPickerDemo multi --detail
```

#### `dynamic` — Dynamic Detail Column

Test dynamic two-column layout where the detail panel updates based on the active item.

```bash
swift run SwiftPickerDemo dynamic [--small] [--multi]
```

**Options:**
- `-s, --small` — Use a smaller list
- `-m, --multi` — Use multi-selection mode

**Examples:**
```bash
# Single selection with dynamic detail
swift run SwiftPickerDemo dynamic

# Multi-selection with dynamic detail
swift run SwiftPickerDemo dynamic --multi
```

#### `choose` — Interactive Menu

Choose which SwiftPicker layout to test using SwiftPicker itself (meta!).

```bash
swift run SwiftPickerDemo choose
```

This command presents a picker menu where you can select from:
- Single Column (Single Selection)
- Single Column (Multi Selection)
- Two Column Static (Single Selection)
- Two Column Static (Multi Selection)
- Two Column Dynamic (Single Selection)
- Two Column Dynamic (Multi Selection)

#### `browse` — Filesystem Browser

Browse your filesystem using tree navigation.

```bash
swift run SwiftPickerDemo browse [--path <path>] [--show-hidden]
```

**Options:**
- `-p, --path <path>` — Starting path (defaults to your home directory)
- `-H, --show-hidden` — Show hidden files and folders

**Examples:**
```bash
# Browse from home directory
swift run SwiftPickerDemo browse

# Browse from specific path
swift run SwiftPickerDemo browse --path ~/Projects

# Show hidden files
swift run SwiftPickerDemo browse --show-hidden
```

## Code Examples

The demo showcases common SwiftPickerKit patterns:

### Single Selection with Layout

```swift
let picker = SwiftPicker()
let items = TestItem.largeList
let layout: PickerLayout<TestItem> = .singleColumn

if let selection = picker.singleSelection(
    prompt: prompt,
    items: items,
    layout: layout,
    newScreen: true
) {
    print("Selected: \(selection.displayName)")
}
```

### Multi-Selection

```swift
let picker = SwiftPicker()
let selections = picker.multiSelection(
    prompt: prompt,
    items: items,
    layout: .singleColumn,
    newScreen: true
)

print("Selected \(selections.count) items")
```

### Dynamic Detail Column

```swift
let detailForItem: (TestItem) -> String = { item in
    """
    \(item.emoji) \(item.name)

    \(item.description)

    Additional Notes:
    \(item.additionalNotes.map { "- \($0)" }.joined(separator: "\n"))
    """
}

let layout: PickerLayout<TestItem> = .twoColumnDynamic(detailForItem: detailForItem)
```

### Tree Navigation

```swift
let picker = SwiftPicker()
let root = FileSystemNode(url: URL(fileURLWithPath: "/Users/you"))

if let selection = picker.treeNavigation(
    prompt: "Browse folders",
    rootItems: [root],
    newScreen: true
) {
    print("Selected: \(selection.url.path)")
}

// Set isSelectable = false on any TreeNodePickerItem to make it navigable-only.
```

## Project Structure

```
SwiftPickerDemo/
├── Package.swift
└── Sources/
    └── SwiftPickerDemo/
        ├── SwiftPickerDemo.swift  # Main CLI app with ArgumentParser
        └── TestItem.swift          # Sample data for demos
```

## Dependencies

- **SwiftPickerKit** — The library being demonstrated (local dependency)
- **[ArgumentParser](https://github.com/apple/swift-argument-parser)** (>= 1.5.0) — CLI argument parsing
- **[Files](https://github.com/JohnSundell/Files)** (>= 4.0.0) — File system operations

## Testing Different Layouts

The demo is organized to help you test all combinations:

| Subcommand | Single/Multi | Layout Options |
|------------|-------------|----------------|
| `single` | Single | Single column or static two-column |
| `multi` | Multi | Single column or static two-column |
| `dynamic` | Both (flag) | Dynamic two-column only |
| `choose` | Interactive | All layouts and modes |
| `browse` | Single | Tree navigation |

## Tips

1. **Try scrolling** — Use the large list option to test scroll indicators
2. **Test keyboard shortcuts** — Each mode has different key bindings (space, enter, arrows, q)
3. **Compare layouts** — Run the same command with and without `--detail` to see the difference
4. **Browse your projects** — Use `browse --path ~/Projects` to navigate real directories
5. **Use `choose`** — The easiest way to explore all picker modes interactively

## License

SwiftPickerDemo is part of the SwiftPickerKit project and is released under the MIT License.
