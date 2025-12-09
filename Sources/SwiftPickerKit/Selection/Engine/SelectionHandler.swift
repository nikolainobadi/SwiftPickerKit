//
//  SelectionHandler.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// The orchestrator that implements SwiftPickerKit's State-Behavior-Renderer architecture.
///
/// `SelectionHandler` is the core engine that powers all picker modes. It coordinates three
/// pluggable components (State, Behavior, Renderer) to create interactive terminal pickers.
///
/// ## State-Behavior-Renderer Pattern
///
/// This pattern cleanly separates picker concerns into three responsibilities:
///
/// ### State (BaseSelectionState)
/// - **What to display** — Items, selections, active index, UI text
/// - **Current picker state** — Which item is focused, what's selected
/// - Holds all data needed for rendering and behavior decisions
///
/// ### Behavior (SelectionBehavior)
/// - **How to respond to input** — Arrow keys, Enter, Space, q, Backspace
/// - **Business logic** — What happens when user presses keys
/// - Modifies state based on user actions
///
/// ### Renderer (ContentRenderer)
/// - **How to draw content** — Single column, two columns, tree navigation
/// - **Visual presentation** — Formatting, colors, indicators
/// - Reads state and draws to terminal
///
/// ## Why This Pattern?
///
/// Separating these concerns makes it easy to:
/// - **Mix and match** — Single-selection with tree layout, multi-selection with two columns
/// - **Add new modes** — Create a new renderer without touching behavior logic
/// - **Test independently** — Unit test state transitions without terminal I/O
/// - **Maintain clarity** — Each component has a single, clear responsibility
///
/// ## Architecture Flow
///
/// ```
/// ┌─────────────────────────────────────────────────────────┐
/// │                    SelectionHandler                      │
/// │                                                          │
/// │  ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
/// │  │  State   │◄───│ Behavior │    │    Renderer      │  │
/// │  │          │    │          │    │                  │  │
/// │  │ • Items  │    │ • Arrows │    │ • Single Column  │  │
/// │  │ • Active │    │ • Enter  │    │ • Two Column     │  │
/// │  │ • Select │    │ • Space  │    │ • Tree View      │  │
/// │  └──────────┘    └──────────┘    └──────────────────┘  │
/// │                                                          │
/// │  Input Loop:                                             │
/// │  1. Read key press                                       │
/// │  2. Behavior updates State                               │
/// │  3. Renderer draws State                                 │
/// │  4. Repeat until selection made                          │
/// └─────────────────────────────────────────────────────────┘
/// ```
///
/// ## Usage (Internal)
///
/// Public APIs (like `SwiftPicker.singleSelection`) create a SelectionHandler with
/// appropriate State, Behavior, and Renderer, then call `captureUserInput()`:
///
/// ```swift
/// let state = SingleSelectionState(items: items, ...)
/// let behavior = SingleSelectionBehavior()
/// let renderer = SingleColumnRenderer()
///
/// let handler = SelectionHandler(
///     state: state,
///     behavior: behavior,
///     renderer: renderer,
///     pickerInput: pickerInput
/// )
///
/// let outcome = handler.captureUserInput()
/// ```
final class SelectionHandler<
    Item: DisplayablePickerItem,
    Behavior: SelectionBehavior,
    Renderer: ContentRenderer
> where
    Behavior.Item == Item,
    Renderer.Item == Item,
    Behavior.State == Renderer.State
{
    /// Behavior component that handles user input and state transitions
    private let behavior: Behavior

    /// Terminal I/O abstraction for reading input and drawing output
    private let pickerInput: PickerInput

    /// Current state of the picker (items, selections, active index, UI text)
    private var state: Behavior.State

    /// Renders the header section (prompt, selected item detail)
    private let headerRenderer: PickerHeaderRenderer

    /// Renders the footer section (instruction text)
    private let footerRenderer: PickerFooterRenderer

    /// Content renderer (pluggable: single-column, two-column, tree, etc.)
    private let contentRenderer: Renderer

    /// Cache of the currently focused item (used for header rendering)
    private var currentSelectedItem: Item?

    /// Creates a new SelectionHandler with the given State, Behavior, and Renderer.
    ///
    /// - Parameters:
    ///   - state: Initial picker state (items, active index, UI text)
    ///   - pickerInput: Terminal I/O interface
    ///   - behavior: Input handler for arrow keys and special characters
    ///   - renderer: Visual renderer for the picker content
    init(
        state: Behavior.State,
        pickerInput: PickerInput,
        behavior: Behavior,
        renderer: Renderer
    ) {
        self.state = state
        self.behavior = behavior
        self.pickerInput = pickerInput

        self.headerRenderer = .init(pickerInput: pickerInput)
        self.footerRenderer = .init(pickerInput: pickerInput)
        self.contentRenderer = renderer
    }
}


// MARK: - Input Loop
extension SelectionHandler {
    /// Main input loop that captures user interactions and returns the selection outcome.
    ///
    /// This is the heart of the picker's runtime. It:
    /// 1. Sets up signal handlers for clean Ctrl+C termination
    /// 2. Renders the initial frame
    /// 3. Enters an input loop reading keypresses
    /// 4. Delegates input to Behavior (which may update State)
    /// 5. Re-renders after each input
    /// 6. Returns when user makes a selection or cancels
    ///
    /// ## Signal Handling
    ///
    /// Registers handlers for SIGINT (Ctrl+C) and SIGTERM to ensure terminal
    /// is properly restored even if the program is interrupted. Without this,
    /// interrupted pickers can leave the terminal in an unusable state.
    ///
    /// ## Input Processing
    ///
    /// The loop distinguishes between:
    /// - **Special characters** (Enter, Space, q, Backspace) — Handled by Behavior,
    ///   may complete the selection
    /// - **Arrow keys** (Up, Down, Left, Right) — Handled by Behavior, update state
    ///   and continue loop
    ///
    /// - Returns: The selection outcome (single item, multiple items, or cancellation)
    func captureUserInput() -> SelectionOutcome<Item> {
        // Register cleanup handlers for SIGINT (Ctrl+C) and SIGTERM
        SignalHandler.setupSignalHandlers { [pickerInput] in
            pickerInput.exitAlternativeScreen()
            pickerInput.enableNormalInput()
        }

        // Ensure cleanup always happens, even if we return early
        defer {
            SignalHandler.removeSignalHandlers()
            endSelection()
        }

        // Draw initial frame
        renderFrame()

        // Main input loop
        while true {
            pickerInput.clearBuffer()

            if pickerInput.keyPressed() {
                // Try reading as a special character first (Enter, Space, q, etc.)
                if let special = pickerInput.readSpecialChar() {
                    let outcome = behavior.handleSpecialChar(
                        char: special,
                        state: state
                    )

                    switch outcome {
                    case .continueLoop:
                        // Behavior says continue (e.g., Space toggled selection)
                        renderFrame()
                        continue
                    case .finishSingle, .finishMulti:
                        // Behavior says we're done (Enter pressed or q cancelled)
                        return outcome
                    }
                }

                // If not a special char, try arrow keys
                handleArrowKeys()
            }
        }
    }

    /// Cleans up terminal state when the picker exits.
    ///
    /// Restores the terminal to normal mode by exiting the alternate screen buffer
    /// and re-enabling normal input mode. Called automatically in `captureUserInput`'s
    /// defer block.
    func endSelection() {
        pickerInput.exitAlternativeScreen()
        pickerInput.enableNormalInput()
    }

    /// Handles arrow key input by delegating to the Behavior.
    ///
    /// Arrow key handling is delegated to the Behavior component because different
    /// picker modes need different navigation logic:
    /// - Single-column: Up/Down navigate, Left/Right do nothing
    /// - Tree navigation: Up/Down navigate, Right descends, Left ascends
    /// - Two-column: Up/Down navigate, Left/Right might switch columns
    ///
    /// After the Behavior updates state, the frame is re-rendered to reflect changes.
    func handleArrowKeys() {
        guard let dir = pickerInput.readDirectionKey() else { return }

        // Delegate to behavior for state update
        // Different behaviors interpret arrows differently (single-column vs tree)
        behavior.handleArrow(direction: dir, state: &state)

        // Re-render to show updated state
        renderFrame()
    }
}


// MARK: - Rendering
private extension SelectionHandler {
    /// Calculates the footer height in terminal rows.
    ///
    /// Delegates to `PickerFooterRenderer` to determine how many rows the footer occupies.
    var footerHeight: Int {
        return footerRenderer.height()
    }

    /// Calculates the header height in terminal rows.
    ///
    /// This calculation must exactly mirror what `PickerHeaderRenderer` outputs.
    /// The header includes:
    /// - Top line (with top-line text)
    /// - Optional prompt section (if `showPromptText` is true)
    /// - Optional selected item detail (if `showSelectedItemText` is true)
    /// - Spacing
    ///
    /// This height is used to calculate how many rows remain for content rendering.
    ///
    /// **Important:** Keep this in sync with `PickerHeaderRenderer.renderHeader()`.
    var headerHeight: Int {
        var height = 0
        height += 1 // top line

        if state.showPromptText {
            height += 1 // divider
            height += state.prompt.split(
                separator: "\n",
                omittingEmptySubsequences: false
            ).count
            height += 1 // blank after prompt
        } else {
            height += 1 // blank after top line
        }

        if state.showSelectedItemText && currentSelectedItem != nil {
            height += 3 // divider + "Selected:" + divider
            height += state.selectedDetailLines.count
            height += 1 // blank after selected block
        }

        height += 1 // spacer before content list
        return height
    }

    /// Renders a complete frame of the picker interface.
    ///
    /// This is called on every state change (arrow key press, selection toggle, etc.).
    /// It orchestrates the full rendering pipeline:
    ///
    /// ## Rendering Pipeline
    ///
    /// 1. **Calculate Layout** — Get terminal size, determine visible rows
    /// 2. **Compute Scroll Bounds** — Use ScrollEngine to determine which items are visible
    /// 3. **Render Header** — Prompt, selected item detail
    /// 4. **Render Scroll Indicators** — Up arrow if scrolled down
    /// 5. **Render Content** — Delegate to ContentRenderer (single-column, tree, etc.)
    /// 6. **Render Footer** — Instruction text
    /// 7. **Render Scroll Indicators** — Down arrow if more items below
    ///
    /// ## Scroll Calculation
    ///
    /// The ScrollEngine determines which slice of items should be visible based on:
    /// - Total number of items
    /// - Available visible rows (terminal height - header - footer)
    /// - Current active index
    ///
    /// This ensures the active item is always visible and scroll indicators appear
    /// when content overflows.
    func renderFrame() {
        // Get current terminal dimensions
        let (rows, cols) = pickerInput.readScreenSize()

        // Determine the currently focused item for header rendering
        let options = state.options
        if let focusAware = state as? any FocusAwareSelectionState<Item> {
            // Complex states (like tree navigation) track focus explicitly
            currentSelectedItem = focusAware.focusedItem
        } else {
            // Simple states use activeIndex
            if options.indices.contains(state.activeIndex) {
                currentSelectedItem = options[state.activeIndex].item
            } else {
                currentSelectedItem = nil
            }
        }

        // Calculate layout dimensions
        let headerH = headerHeight
        let footerH = footerHeight
        let visibleRows = max(1, rows - headerH - footerH)

        // Compute scroll bounds using ScrollEngine
        let engine = ScrollEngine(totalItems: options.count, visibleRows: visibleRows)
        let (start, end) = engine.bounds(activeIndex: state.activeIndex)
        let showUp = engine.showScrollUp(start: start)
        let showDown = engine.showScrollDown(end: end)

        // Render header (prompt, selected item detail)
        headerRenderer.renderHeader(
            prompt: state.prompt,
            topLineText: state.topLineText,
            selectedItem: currentSelectedItem,
            selectedDetailLines: state.selectedDetailLines,
            showSelectedItemText: state.showSelectedItemText,
            showPromptText: state.showPromptText,
            screenWidth: cols
        )

        // Render main content (delegated to pluggable ContentRenderer)
        let context = ScrollRenderContext(
            startIndex: start,
            endIndex: end,
            listStartRow: headerH,
            visibleRowCount: visibleRows
        )
        let items = options.map { $0.item }
        contentRenderer.render(
            items: items,
            state: state,
            context: context,
            input: pickerInput,
            screenWidth: cols
        )

        // Render footer (instruction text)
        footerRenderer.renderFooter(instructionText: state.bottomLineText)

        // Delegate scroll indicator rendering to content renderer
        // (allows column-based renderers to customize positioning)
        contentRenderer.renderScrollIndicators(
            showUp: showUp,
            showDown: showDown,
            state: state,
            context: context,
            input: pickerInput,
            screenWidth: cols,
            headerHeight: headerH,
            totalRows: rows
        )
    }
}


// MARK: - Dependencies
/// The outcome of a picker input loop iteration.
///
/// Used by `SelectionBehavior` to signal whether the picker should continue
/// running or return a selection result.
enum SelectionOutcome<Item> {
    /// Continue the input loop (e.g., after Space toggles a selection)
    case continueLoop

    /// Complete single-selection and return the selected item (or nil if cancelled)
    case finishSingle(Item?)

    /// Complete multi-selection and return all selected items
    case finishMulti([Item])
}

/// Protocol for content renderers in the State-Behavior-Renderer pattern.
///
/// Content renderers are responsible for drawing the main list of items to the terminal.
/// Different renderers provide different visual layouts:
/// - `SingleColumnRenderer` — Vertical list
/// - `TwoColumnStaticDetailRenderer` — List + static detail panel
/// - `TwoColumnDynamicDetailRenderer` — List + dynamic detail panel
/// - `TreeNavigationRenderer` — Breadcrumb path + current level items
///
/// ## Responsibilities
///
/// - Read state to determine which items are active/selected
/// - Render only the visible slice (determined by ScrollRenderContext)
/// - Apply formatting, colors, indicators (arrows, checkmarks)
/// - Position content correctly within the terminal
///
/// ## Example
///
/// ```swift
/// struct SingleColumnRenderer: ContentRenderer {
///     func render(items: [Item], state: SingleSelectionState<Item>, ...) {
///         // Draw each visible item with cursor indicator
///         for (index, item) in visibleItems.enumerated() {
///             let indicator = index == state.activeIndex ? ">" : " "
///             print("\(indicator) \(item.displayName)")
///         }
///     }
/// }
/// ```
protocol ContentRenderer {
    associatedtype State
    associatedtype Item: DisplayablePickerItem

    /// Renders the picker's main content area.
    ///
    /// - Parameters:
    ///   - items: All items in the picker
    ///   - state: Current picker state (active index, selections, etc.)
    ///   - context: Scroll context specifying which items are visible
    ///   - input: Terminal I/O interface for drawing
    ///   - screenWidth: Terminal width in columns
    func render(items: [Item], state: State, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int)

    /// Renders scroll indicators (up/down arrows) when content overflows.
    ///
    /// Override this method to customize scroll indicator positioning for specialized layouts
    /// (e.g., column-based navigation). The default implementation renders standard arrows
    /// at the top and bottom of the content area.
    ///
    /// - Parameters:
    ///   - showUp: Whether to show the up scroll indicator
    ///   - showDown: Whether to show the down scroll indicator
    ///   - state: Current picker state
    ///   - context: Scroll context specifying visible bounds
    ///   - input: Terminal I/O interface for drawing
    ///   - screenWidth: Terminal width in columns
    ///   - headerHeight: Height of the header section in rows
    ///   - totalRows: Total terminal height in rows
    func renderScrollIndicators(showUp: Bool, showDown: Bool, state: State, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int, headerHeight: Int, totalRows: Int)
}

extension ContentRenderer {
    /// Default scroll indicator rendering for standard single-column layouts.
    ///
    /// Renders up arrow just above the content area and down arrow just below it.
    /// Column-based renderers can override this to position arrows per column.
    func renderScrollIndicators(showUp: Bool, showDown: Bool, state: State, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int, headerHeight: Int, totalRows: Int) {
        let scrollRenderer = ScrollRenderer(pickerInput: input)
        let footerRenderer = PickerFooterRenderer(pickerInput: input)

        if showUp {
            let arrowRow = headerHeight - 1
            scrollRenderer.renderUpArrow(at: arrowRow)
        }

        if showDown {
            let footerStartRow = totalRows - footerRenderer.height()
            scrollRenderer.renderDownArrow(at: footerStartRow)
        }
    }
}

/// Protocol for input handlers in the State-Behavior-Renderer pattern.
///
/// Behaviors define how the picker responds to user input. Different behaviors
/// implement different interaction models:
/// - `SingleSelectionBehavior` — Enter selects, q cancels
/// - `MultiSelectionBehavior` — Space toggles, Enter confirms, q cancels
/// - `TreeNavigationBehavior` — Right descends, Left ascends, Enter selects
///
/// ## Responsibilities
///
/// - Handle arrow keys (update activeIndex or navigate tree)
/// - Handle special characters (Enter, Space, q, Backspace)
/// - Update state based on user actions
/// - Signal when selection is complete (return finish outcome)
///
/// ## Example
///
/// ```swift
/// struct SingleSelectionBehavior: SelectionBehavior {
///     func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item> {
///         switch char {
///         case .enter:
///             return .finishSingle(state.options[state.activeIndex].item)
///         case .quit:
///             return .finishSingle(nil)
///         default:
///             return .continueLoop
///         }
///     }
/// }
/// ```
protocol SelectionBehavior {
    associatedtype Item: DisplayablePickerItem
    associatedtype State: BaseSelectionState<Item>

    /// Handles arrow key input and updates state accordingly.
    ///
    /// Default implementation handles Up/Down for vertical navigation.
    /// Override to customize (e.g., tree navigation handles Left/Right).
    ///
    /// - Parameters:
    ///   - direction: The arrow key direction pressed
    ///   - state: Current picker state (modified in-place)
    func handleArrow(direction: Direction, state: inout State)

    /// Handles special character input (Enter, Space, q, Backspace).
    ///
    /// Returns a `SelectionOutcome` indicating whether to continue the input
    /// loop or complete the selection.
    ///
    /// - Parameters:
    ///   - char: The special character pressed
    ///   - state: Current picker state (read-only)
    /// - Returns: Outcome signaling whether to continue or finish
    func handleSpecialChar(char: SpecialChar, state: State) -> SelectionOutcome<Item>
}

extension SelectionBehavior {
    /// Default arrow key handler for simple vertical navigation.
    ///
    /// This provides standard Up/Down behavior:
    /// - Up: Decrement activeIndex (if not already at top)
    /// - Down: Increment activeIndex (if not already at bottom)
    /// - Left/Right: No-op (override in behaviors that need them)
    ///
    /// Override this method for custom navigation (e.g., tree navigation
    /// needs to handle Left/Right for ascending/descending hierarchy).
    func handleArrow(direction: Direction, state: inout State) {
        switch direction {
        case .up:
            if state.activeIndex > 0 {
                state.activeIndex -= 1
            }
        case .down:
            if state.activeIndex < state.options.count - 1 {
                state.activeIndex += 1
            }
        case .left, .right:
            // No-op by default; override if needed
            break
        }
    }
}
