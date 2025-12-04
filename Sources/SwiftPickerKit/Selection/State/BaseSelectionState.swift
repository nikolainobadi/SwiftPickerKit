//
//  BaseSelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// State protocol in the State-Behavior-Renderer pattern.
///
/// `BaseSelectionState` defines the contract for picker state implementations. State objects
/// hold all data needed to render the picker and make behavior decisions:
/// - Which items to display
/// - Which item is currently active (cursor position)
/// - Which items are selected (for multi-selection)
/// - UI text (prompt, instructions, titles)
///
/// ## State Responsibility
///
/// State is purely **data** — it doesn't handle input or draw to the terminal. It simply
/// provides the information that Behavior reads/modifies and Renderer displays.
///
/// ## Implementations
///
/// Different picker modes have different state implementations:
/// - `SingleSelectionState` — Tracks active index for single-column list
/// - `MultiSelectionState` — Tracks multiple selections with checkmarks
/// - `TwoColumnDynamicDetailState` — Tracks active index + detail content per item
/// - `TreeNavigationState` — Tracks current tree level, breadcrumb path, navigation stack
///
/// ## Example
///
/// ```swift
/// struct SingleSelectionState<Item: DisplayablePickerItem>: BaseSelectionState {
///     var activeIndex: Int
///     let options: [Option<Item>]
///     let prompt: String
///     let topLineText: String
///     let bottomLineText: String
///
///     init(items: [Item], prompt: String) {
///         self.activeIndex = 0
///         self.options = items.map { Option(item: $0, isSelected: false) }
///         self.prompt = prompt
///         self.topLineText = "SwiftPicker"
///         self.bottomLineText = "↑↓: Navigate | Enter: Select | q: Cancel"
///     }
/// }
/// ```
protocol BaseSelectionState<Item> {
    associatedtype Item: DisplayablePickerItem

    /// The index of the currently active (focused/highlighted) item.
    ///
    /// Used by Behavior to track cursor position and by Renderer to highlight the active item.
    /// Behavior updates this in response to arrow keys.
    var activeIndex: Int { get set }

    /// All items in the picker with their selection status.
    ///
    /// Wrapped in `Option<Item>` to track whether each item is selected (for multi-selection).
    /// Single-selection pickers typically have all `isSelected = false`.
    var options: [Option<Item>] { get }

    /// The main prompt text displayed in the header.
    ///
    /// Can be multi-line (separated by `\n`). Automatically wrapped to fit terminal width.
    var prompt: String { get }

    /// Text displayed at the top of the header (e.g., "SwiftPicker" or app name).
    var topLineText: String { get }

    /// Instruction text displayed in the footer (e.g., "↑↓: Navigate | Enter: Select").
    var bottomLineText: String { get }

    /// Additional detail lines shown below the selected item in the header.
    ///
    /// Used by dynamic detail pickers to show item-specific information.
    /// Default implementation returns empty array.
    var selectedDetailLines: [String] { get }

    /// Whether to show the selected item text in the header.
    ///
    /// When `true`, displays "Selected: [item name]" in the header.
    /// Default implementation returns `true`.
    var showSelectedItemText: Bool { get }

    /// Whether to show the prompt text in the header.
    ///
    /// When `false`, hides the prompt for cleaner UI (useful for tree navigation).
    /// Default implementation returns `true`.
    var showPromptText: Bool { get }

    /// Toggles the selection status of the item at the given index.
    ///
    /// Used by multi-selection behaviors when Space is pressed. Single-selection
    /// states can use the default no-op implementation.
    ///
    /// - Parameter index: The index of the item to toggle
    func toggleSelection(at index: Int)
}

extension BaseSelectionState {
    /// Default: No additional detail lines.
    var selectedDetailLines: [String] { [] }

    /// Default: Show selected item text in header.
    var showSelectedItemText: Bool { true }

    /// Default: Show prompt text in header.
    var showPromptText: Bool { true }

    /// Default: No-op (single-selection states don't toggle).
    func toggleSelection(at index: Int) { }
}

/// Extended state protocol for pickers with complex focus tracking.
///
/// Some picker modes (like tree navigation) need to track which item is "focused"
/// separately from which items are visible in the list. This protocol provides
/// that distinction.
///
/// ## When to Use
///
/// Use this when:
/// - The visible list differs from the full item set (e.g., tree navigation shows current level)
/// - You need to display focused item details in the header that aren't in the visible list
/// - The `activeIndex` refers to visible items, but you need the actual focused item
///
/// ## Example
///
/// Tree navigation shows the current directory's children, but the focused item
/// might be a parent directory shown in the breadcrumb. `FocusAwareSelectionState`
/// lets the header renderer access that parent item for display.
protocol FocusAwareSelectionState<Item>: BaseSelectionState {
    /// The item currently focused, which may not be in the visible list.
    ///
    /// Used by header renderer to display focused item details even when that
    /// item isn't in the current visible list (e.g., parent directory in tree nav).
    var focusedItem: Item? { get }
}
