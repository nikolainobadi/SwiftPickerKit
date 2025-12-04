# SwiftPickerKit

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![macOS](https://img.shields.io/badge/macOS-13.0+-blueviolet.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Demo](#demo)
- [Usage](#usage)
  - [Basic Single Selection](#basic-single-selection)
  - [Multi-Selection](#multi-selection)
  - [Controlling Header Display](#controlling-header-display)
  - [Two-Column Layout with Static Detail](#two-column-layout-with-static-detail)
  - [Two-Column Layout with Dynamic Detail](#two-column-layout-with-dynamic-detail)
  - [Tree Navigation](#tree-navigation)
  - [Text Input & Permissions](#text-input--permissions)
  - [Custom Types](#custom-types)
- [Architecture](#architecture)
- [Testing](#testing)
- [Dependencies](#dependencies)
- [Backstory](#backstory)
- [Acknowledgements](#acknowledgements)
- [Contributing](#contributing)
- [License](#license)

## Overview

SwiftPickerKit is a Swift Package Manager library for building interactive terminal-based pickers with support for single-selection, multi-selection, two-column layouts, and hierarchical tree navigation. The package provides a clean, protocol-oriented API for creating command-line interfaces with rich visual feedback and keyboard navigation.

## Features

- **Single & Multi-Selection** — Choose one or multiple items from lists with visual markers
- **Two-Column Layouts** — Display items with static or dynamic detail panels
- **Tree Navigation** — Browse hierarchical structures with breadcrumb paths and parent/child columns
- **Text Input & Permissions** — Prompt users for text input or yes/no confirmations
- **Customizable Layouts** — Configure single-column, static two-column, or dynamic two-column rendering
- **Scroll Support** — Automatic scrolling with visual indicators for large lists
- **Terminal Control** — Built on ANSITerminal for full terminal manipulation
- **Testing Support** — Includes `SwiftPickerTesting` module with `MockSwiftPicker` for unit tests
- **State-Behavior-Renderer Architecture** — Clean separation between state management, input handling, and rendering

## Requirements

- macOS 13.0+
- Swift 5.9+
- Xcode 16.2+ (for development)

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:
```swift
    .package(url: "https://github.com/nikolainobadi/SwiftPickerKit", from: "0.6.0")
```

Then include it in your target dependencies:
```swift
    .product(name: "SwiftPickerKit", package: "SwiftPickerKit")
```

Include this in your test target dependencies:
```swift
    .product(name: "SwiftPickerTesting", package: "SwiftPickerKit")
```

## Demo

Want to see SwiftPickerKit in action before integrating it? Check out the [**SwiftPickerDemo**](SwiftPickerDemo/README.md) — a complete interactive demonstration of all features with detailed documentation and examples.

Run the demo from the package root:
```bash
cd SwiftPickerDemo
swift run SwiftPickerDemo <subcommand>
```

### Available Subcommands

- **`single`** — Single-selection picker
  - `-r, --required` — Require a selection (throws if none made)
  - `-s, --small` — Use a smaller non-scrolling list
  - `-d, --detail` — Show static detail column

- **`multi`** — Multi-selection picker
  - `-s, --small` — Use a smaller non-scrolling list
  - `-d, --detail` — Show static detail column

- **`dynamic`** — Dynamic two-column detail picker
  - `-s, --small` — Use a smaller list
  - `-m, --multi` — Use multi-selection mode

- **`choose`** — Interactive menu to test all layouts and modes using SwiftPicker itself

- **`browse`** — Filesystem browser with tree navigation
  - `-p, --path <path>` — Starting path (defaults to home directory)
  - `-H, --show-hidden` — Show hidden files and folders

### Quick Start

Try the interactive chooser to explore all features:
```bash
cd SwiftPickerDemo
swift run SwiftPickerDemo choose
```

Or test a specific feature:
```bash
swift run SwiftPickerDemo single -d      # Single selection with detail column
swift run SwiftPickerDemo multi -s       # Multi selection with small list
swift run SwiftPickerDemo dynamic -m     # Dynamic detail with multi-select
swift run SwiftPickerDemo browse -p ~/Documents  # Browse filesystem starting at Documents
```

## Usage

### Basic Single Selection

```swift
import SwiftPickerKit

let picker = SwiftPicker()
let items = ["Option 1", "Option 2", "Option 3"]

if let selected = picker.singleSelection(
    prompt: "Choose an option",
    items: items,
    layout: .singleColumn,
    newScreen: true
) {
    print("Selected: \(selected)")
}
```

### Multi-Selection

```swift
let picker = SwiftPicker()
let items = ["Feature A", "Feature B", "Feature C"]

let selected = picker.multiSelection(
    prompt: "Select features",
    items: items,
    layout: .singleColumn,
    newScreen: true
)

print("Selected \(selected.count) items")
```

### Controlling Header Display

The `showSelectedItemText` parameter controls whether the currently selected item's text is displayed in the picker header:

```swift
let picker = SwiftPicker()
let items = ["Option 1", "Option 2", "Option 3"]

// Show selected item text in header (default: true)
picker.singleSelection(
    prompt: "Choose an option",
    items: items,
    layout: .singleColumn,
    newScreen: true,
    showSelectedItemText: true
)

// Hide selected item text from header
picker.singleSelection(
    prompt: "Choose an option",
    items: items,
    layout: .singleColumn,
    newScreen: true,
    showSelectedItemText: false
)
```

This parameter is available for all selection methods: `singleSelection`, `multiSelection`, and `treeNavigation`.

### Two-Column Layout with Static Detail

```swift
let picker = SwiftPicker()
let items = ["Red", "Green", "Blue"]
let detailText = "Choose your favorite color.\nThis text remains static."

if let color = picker.singleSelection(
    prompt: "Pick a color",
    items: items,
    layout: .twoColumnStatic(detailText: detailText),
    newScreen: true
) {
    print("You chose: \(color)")
}
```

### Two-Column Layout with Dynamic Detail

```swift
struct Task: DisplayablePickerItem {
    let name: String
    let description: String

    var displayName: String { name }
}

let picker = SwiftPicker()
let tasks = [
    Task(name: "Review PR", description: "Check code quality and tests"),
    Task(name: "Write docs", description: "Update API documentation")
]

if let task = picker.singleSelection(
    prompt: "Select a task",
    items: tasks,
    layout: .twoColumnDynamic { $0.description },
    newScreen: true
) {
    print("Task: \(task.name)")
}
```

### Tree Navigation

```swift
import SwiftPickerKit

let picker = SwiftPicker()
let rootNode = FileSystemNode(url: URL(fileURLWithPath: "/Users/you/Projects"))
let root = TreeNavigationRoot(items: [rootNode])

if let selected = picker.treeNavigation(
    prompt: "Browse files",
    root: root,
    newScreen: true
) {
    print("Selected: \(selected.url.path)")
}

// Conform to TreeNodePickerItem protocol for custom tree types
// Mark any TreeNodePickerItem with isSelectable = false to prevent selection (e.g., folders).
```

### Text Input & Permissions

```swift
let picker = SwiftPicker()

// Get text input
let name = picker.getInput(prompt: "Enter your name:")

// Get required input (throws if empty)
let email = try picker.getRequiredInput(prompt: "Enter email:")

// Get permission
if picker.getPermission(prompt: "Continue?") {
    print("User confirmed")
}
```

### Custom Types

Conform your types to `DisplayablePickerItem`:

```swift
struct User: DisplayablePickerItem {
    let id: String
    let name: String
    let email: String  // Custom property, not required by protocol

    var displayName: String { name }
}

let users = [
    User(id: "1", name: "Alice", email: "alice@example.com"),
    User(id: "2", name: "Bob", email: "bob@example.com")
]

let picker = SwiftPicker()
if let user = picker.singleSelection(
    prompt: "Select user",
    items: users,
    layout: .singleColumn,
    newScreen: true
) {
    print("Selected user: \(user.name) (\(user.email))")
}
```

For tree navigation, conform to `TreeNodePickerItem`:

```swift
struct Category: TreeNodePickerItem {
    let name: String
    let subcategories: [Category]
    let canSelect: Bool

    var displayName: String { name }
    var hasChildren: Bool { !subcategories.isEmpty }
    var isSelectable: Bool { canSelect }
    var metadata: TreeNodeMetadata? { nil }

    func loadChildren() -> [Category] {
        return subcategories
    }
}

let root = TreeNavigationRoot(items: [
    Category(name: "Electronics", subcategories: [
        Category(name: "Laptops", subcategories: [], canSelect: true),
        Category(name: "Phones", subcategories: [], canSelect: true)
    ], canSelect: false)
])

let picker = SwiftPicker()
if let category = picker.treeNavigation(
    prompt: "Select category",
    root: root,
    newScreen: true
) {
    print("Selected: \(category.name)")
}
```

## Architecture

SwiftPickerKit uses a **State-Behavior-Renderer** pattern:

- **State** (`BaseSelectionState`) — Tracks current selection, active index, options, and UI text
- **Behavior** (`SelectionBehavior`) — Handles arrow keys and special characters (enter/space/quit/backspace)
- **Renderer** (`ContentRenderer`) — Draws visible content to the terminal

The `SelectionHandler` orchestrates these three components in a render loop, managing signal handling, scrolling, header/footer rendering, and user input capture.

### Key Components

- **Core/** — `SwiftPicker` entry point, protocols, error types, signal handling
- **Picker/** — Public API extensions for each picker mode
- **Selection/** — Internal state/behavior/renderer implementations
- **Rendering/** — Shared rendering utilities (header, footer, scroll, text formatting)
- **Input/** — Default implementations wrapping ANSITerminal

## Testing

The package includes a `SwiftPickerTesting` module with `MockSwiftPicker` for testing without terminal I/O:

```swift
import Testing
import SwiftPickerTesting

@Test func testSelection() {
    let mock = MockSwiftPicker(
        selectionResult: .init(
            defaultSingle: .index(0),
            singleType: .ordered([.index(0)])
        )
    )

    let result = mock.singleSelection(
        prompt: "Test",
        items: ["Expected", "Other"],
        layout: .singleColumn,
        newScreen: false
    )

    #expect(result == "Expected")
}
```

## Dependencies

- [ANSITerminalModified](https://github.com/nikolainobadi/ANSITerminalModified) (>= 0.6.0) — Terminal control and ANSI escape sequences

## Backstory
I think programming is one of the few fields where 'specialized laziness' is actually a superpower. While building custom command line tools may seem like a daunting task to some, I see it as a way to never have to waste time on the boring portions of my workflow ever again. But I'm an iOS developer. When I write code, I prefer to do it in Swift. Unfortunately, there aren't many Swift libraries for command line tools. And I feel like it's a catch-22 because nobody wants to write libraries for the command line using Swift because there aren't many libraries out there to help them, and there aren't many libraries out there because nobody wants to write them, and round and round we go.

`SwiftPickerKit` is simply my contribution to the (hopefully growing) ecosystem of Swift command line tools. It's easy to use, relatively lightweight, and best of all, it helps me write more command line tools to feed my 'specialized laziness'.

## Acknowledgements

This project was inspired by [How to Make an Interactive Picker for a Swift Command-Line Tool](https://www.polpiella.dev/how-to-make-an-interactive-picker-for-a-swift-command-line-tool/) by Pol Piella Abadia. Special thanks for the great tutorial.

## Contributing

Contributions are welcome! If you'd like to add a new feature, improve an existing feature, or fix a bug:

1. Fork the repository
2. Create your feature branch
3. Submit a PR with a clear description

Issues and suggestions are also welcome via [GitHub Issues](https://github.com/nikolainobadi/swiftpickerkit/issues/new)

## License

SwiftPickerKit is released under the MIT License. See [LICENSE](LICENSE) for details.
