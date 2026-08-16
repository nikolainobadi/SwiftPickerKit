# Tree Navigation API

Hierarchical tree navigation, custom tree nodes, and file system directory browsing.

---

## Protocol: CommandLineTreeNavigation

Tree navigation and directory browsing pickers.

```swift
public protocol CommandLineTreeNavigation {
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String, root: TreeNavigationRoot<Item>,
        showPromptText: Bool, showSelectedItemText: Bool
    ) -> Item?

    func browseDirectories(
        prompt: String, startURL: URL,
        showPromptText: Bool, showSelectedItemText: Bool,
        selectionType: FileSystemNode.SelectionType
    ) -> FileSystemNode?
}
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `treeNavigation(prompt:root:showPromptText:showSelectedItemText:)` | `Item?` | Hierarchical picker with left/right navigation; `nil` if cancelled |
| `requiredTreeNavigation(prompt:root:showPromptText:showSelectedItemText:) throws` | `Item` | Throws `.selectionCancelled` if user quits |
| `requiredTreeNavigation(prompt:root:flagHint:showPromptText:showSelectedItemText:) throws` | `Item` | Throws `PickerRequirementError.missingSelection` naming the CLI flag that supplies the choice |
| `browseDirectories(prompt:startURL:showPromptText:showSelectedItemText:selectionType:)` | `FileSystemNode?` | File system browser starting at given URL |

### Default Parameter Values

- `showPromptText: true`
- `showSelectedItemText: true`
- `selectionType: .filesAndFolders`

### Navigation Controls

- **Up/Down arrows** — Move highlight within the current column
- **Right arrow** — Descend into highlighted item's children (if it has children)
- **Left arrow (first press)** — Focus shifts to parent column
- **Left arrow (second press)** — Ascend to parent level
- **Enter** — Select the highlighted item (only if `isSelectable` is true)
- **Quit** — Cancel and return `nil`

### Screen Behavior

`treeNavigation` **always** enters the alternative screen buffer — there is no `newScreen` parameter. Both `enterAlternativeScreen()` and `exitAlternativeScreen()` are called unconditionally.

### Rendering Layout

Two columns when a parent level exists: parent items on the left, current items on the right. Breadcrumb path displayed above columns showing navigation trail with ` ▸ ` separators.

### Empty Folder Handling

When descending into a folder with no children, the picker displays an orange hint message (e.g., `"'FolderName' is empty"`) and stays at the current level. No new level is pushed onto the navigation stack.

### Usage Example

```swift
let picker = SwiftPicker()

// Custom tree items
let root = TreeNavigationRoot(displayName: "Settings", children: [
    TreeNode(name: "General", value: "general", hasChildren: true) {
        [TreeNode(name: "Theme", value: "theme"),
         TreeNode(name: "Language", value: "language")]
    },
    TreeNode(name: "Advanced", value: "advanced")
])

if let selected = picker.treeNavigation(prompt: "Navigate settings:", root: root) {
    print("Selected: \(selected.value)")
}
```

---

## Protocol: TreeNodePickerItem

Items that can appear in tree navigation pickers. Extends `DisplayablePickerItem`.

```swift
public protocol TreeNodePickerItem: DisplayablePickerItem {
    var hasChildren: Bool { get }
    var isSelectable: Bool { get }
    var metadata: TreeNodeMetadata? { get }
    func loadChildren() -> [Self]
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `hasChildren` | `Bool` | Whether this item can be expanded to show children |
| `isSelectable` | `Bool` | Whether enter key can select this item |
| `metadata` | `TreeNodeMetadata?` | Optional subtitle, detail lines, and icon |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadChildren()` | `[Self]` | Returns child items; called when user navigates into this item |

### Usage Example

```swift
struct Category: TreeNodePickerItem {
    let displayName: String
    let subcategories: [Category]

    var hasChildren: Bool { !subcategories.isEmpty }
    var isSelectable: Bool { subcategories.isEmpty } // Only leaf nodes selectable
    var metadata: TreeNodeMetadata? { nil }

    func loadChildren() -> [Category] { subcategories }
}
```

---

## Struct: TreeNodeMetadata

Optional metadata displayed alongside tree items.

```swift
public struct TreeNodeMetadata {
    public var subtitle: String?
    public var detailLines: [String]
    public var icon: String?

    public init(subtitle: String? = nil, detailLines: [String] = [], icon: String? = nil)
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `subtitle` | `String?` | Secondary text shown below the item name |
| `detailLines` | `[String]` | Additional detail lines shown in the detail panel |
| `icon` | `String?` | Icon character displayed before the item name |

### Usage Example

```swift
let metadata = TreeNodeMetadata(
    subtitle: "3 items",
    detailLines: ["Last modified: 2025-01-15", "Size: 4.2 MB"],
    icon: "📁"
)
```

---

## Struct: TreeNode

Generic tree node wrapping any value type. Conforms to `TreeNodePickerItem`.

```swift
public struct TreeNode<T>: TreeNodePickerItem {
    public let displayName: String
    public let value: T
    public let metadata: TreeNodeMetadata?
    public let isSelectable: Bool
    public var hasChildren: Bool { get }

    public init(
        name: String, value: T,
        hasChildren: Bool = false,
        isSelectable: Bool = true,
        metadata: TreeNodeMetadata? = nil,
        loadChildren: @escaping () -> [TreeNode<T>]
    )

    public func loadChildren() -> [TreeNode<T>]
}
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(name:value:hasChildren:isSelectable:metadata:loadChildren:)` | Creates a node; `loadChildren` closure is called lazily on navigation |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `displayName` | `String` | Display text for this node |
| `value` | `T` | The wrapped value extracted on selection |
| `metadata` | `TreeNodeMetadata?` | Optional metadata for display |
| `isSelectable` | `Bool` | Whether this node can be selected with enter |
| `hasChildren` | `Bool` | Computed; true if `hasChildren` was set in init or cached children exist |

### Usage Example

```swift
let node = TreeNode(name: "Documents", value: "/docs", hasChildren: true) {
    [TreeNode(name: "README.md", value: "/docs/README.md"),
     TreeNode(name: "CHANGELOG.md", value: "/docs/CHANGELOG.md")]
}
```

---

## Struct: TreeNavigationRoot

Container for the root level of a tree navigation picker.

```swift
public struct TreeNavigationRoot<Item: TreeNodePickerItem> {
    public let displayName: String
    public let children: [Item]

    public init(displayName: String, children: [Item])
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `displayName` | `String` | Label shown at the top of the navigation |
| `children` | `[Item]` | The initial items displayed at root level |

### Navigation Constraint

When a `TreeNavigationRoot` is constructed with a `displayName`, left-arrow navigation cannot ascend past the root contents level. The user stays within the root's children hierarchy.

### Usage Example

```swift
let items: [TreeNode<String>] = [...]
let root = TreeNavigationRoot(displayName: "Project", children: items)
let selection = picker.treeNavigation(prompt: "Browse:", root: root)
```

---

## Struct: FileSystemNode

Concrete `TreeNodePickerItem` for file system browsing.

```swift
public struct FileSystemNode: TreeNodePickerItem {
    public let url: URL
    public var metadata: TreeNodeMetadata?
    public var displayName: String { get }  // url.lastPathComponent
    public var hasChildren: Bool { get }    // true if directory
    public var isSelectable: Bool { get }   // controlled by FileSystemNode.selectionType

    public init(url: URL)
    public func loadChildren() -> [FileSystemNode]
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `url` | `URL` | File system path for this node |
| `displayName` | `String` | Last path component of the URL |
| `hasChildren` | `Bool` | True if the URL points to a directory |
| `isSelectable` | `Bool` | Determined by the static `selectionType` at call time |

### Static Configuration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `selectionType` | `SelectionType` | `.filesAndFolders` | Controls which nodes are selectable |
| `showHiddenFiles` | `Bool` | `false` | Whether dot-prefix files appear in `loadChildren()` |

### Enum: FileSystemNode.SelectionType

| Case | Description |
|------|-------------|
| `onlyFiles` | Only files (non-directories) can be selected |
| `onlyFolders` | Only directories can be selected |
| `filesAndFolders` | Everything is selectable |

### loadChildren() Behavior

Returns directory contents sorted case-insensitively by name. Hidden files (dot-prefix) are excluded unless `showHiddenFiles` is `true`. Returns empty array for non-directory nodes.

### Global State Warning

`FileSystemNode.selectionType` and `FileSystemNode.showHiddenFiles` are **static variables** — setting them affects all `FileSystemNode` instances process-wide. `browseDirectories` sets `selectionType` before navigation and does not reset it afterward.

### Usage Example

```swift
// Direct usage
let root = FileSystemNode(url: URL(fileURLWithPath: "/Users"))
let children = root.loadChildren()

// Via browseDirectories convenience
let selected = picker.browseDirectories(
    prompt: "Select a Swift file:",
    startURL: URL(fileURLWithPath: NSHomeDirectory()),
    selectionType: .onlyFiles
)
if let node = selected {
    print("Selected: \(node.url.path)")
}
```

---

## Best Practices

- **Use `browseDirectories` for filesystem browsing** — It handles `TreeNavigationRoot` construction and `selectionType` configuration automatically. Use `treeNavigation` directly only for custom `TreeNodePickerItem` types.
- **`treeNavigation` always enters alternative screen** — Unlike `singleSelection`/`multiSelection`, there is no `newScreen` parameter. The alternative screen is always used.
- **Non-selectable nodes block enter** — Set `isSelectable: false` on category/folder nodes that should only be navigated into, not selected. Enter key is ignored on non-selectable items.
- **`FileSystemNode.selectionType` is global mutable state** — If you call `browseDirectories` with `.onlyFiles`, that setting persists after the call returns. Reset it manually if needed before subsequent `FileSystemNode` operations.
- **`loadChildren()` is called on descent** — The closure is invoked each time the user navigates into a node. For expensive operations, consider caching within your `TreeNodePickerItem` implementation.
- **Breadcrumb shows navigation path** — The breadcrumb trail (`Parent ▸ Child ▸ ...`) updates automatically. Items at each level contribute their `displayName` to the path.
