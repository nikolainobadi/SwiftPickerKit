# SwiftPickerKit

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![macOS](https://img.shields.io/badge/macOS-12.0+-blueviolet.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
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
- [License](#license)
- [Contributing](#contributing)

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

- macOS 12.0+
- Swift 5.9+
- Xcode 16.2+ (for development)

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/SwiftPickerKit", from: "0.6.0")
]
```

Then include it in your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SwiftPickerKit", package: "SwiftPickerKit"),
        ]
),
.testTarget(
    name: "YourTestTarget",
    dependencies: [
        "YourTarget",
        .product(name: "SwiftPickerTesting", package: "SwiftPickerKit")
    ]
),
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
let root = FileSystemNode(url: URL(fileURLWithPath: "/Users/you/Projects"))

if let selected = picker.treeNavigation(
    prompt: "Browse files",
    rootItems: [root],
    newScreen: true
) {
    print("Selected: \(selected.url.path)")
}

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

    var displayName: String { name }
}

let users = [
    User(id: "1", name: "Alice"),
    User(id: "2", name: "Bob")
]

let picker = SwiftPicker()
if let user = picker.singleSelection(
    prompt: "Select user",
    items: users,
    layout: .singleColumn,
    newScreen: true
) {
    print("Selected user ID: \(user.id)")
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
    var mock = MockSwiftPicker(
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

Run tests with:

```bash
swift test
swift test --enable-code-coverage  # with coverage
```

## Dependencies

- [ANSITerminalModified](https://github.com/nikolainobadi/ANSITerminalModified) (>= 0.6.0) — Terminal control and ANSI escape sequences

## License

SwiftPickerKit is released under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`swift test`)
4. Commit your changes (`git commit -m 'add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request
