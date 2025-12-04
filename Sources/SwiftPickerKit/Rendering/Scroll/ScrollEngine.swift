//
//  ScrollEngine.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Calculates visible item bounds and scroll indicator visibility for picker lists.
///
/// When a picker has more items than fit on screen, `ScrollEngine` determines:
/// 1. Which slice of items should be visible
/// 2. Whether to show up/down scroll arrows
///
/// ## Algorithm
///
/// The engine uses **centered scrolling**: it tries to keep the active item centered
/// in the visible area. This provides optimal context by showing items both above
/// and below the cursor.
///
/// As the user navigates:
/// - **Top of list** — Shows items [0...visibleRows), no centering
/// - **Middle of list** — Centers active item, shows [active - half...active + half)
/// - **Bottom of list** — Shows last visibleRows items, no centering
///
/// ## Example
///
/// ```swift
/// // 100 items, 10 visible rows, active index = 50
/// let engine = ScrollEngine(totalItems: 100, visibleRows: 10)
/// let (start, end) = engine.bounds(activeIndex: 50)
/// // Result: start = 45, end = 55 (active item centered)
///
/// // Check if scroll indicators needed
/// engine.showScrollUp(start: start)   // true (items above)
/// engine.showScrollDown(end: end)     // true (items below)
/// ```
struct ScrollEngine {
    /// Total number of items in the full list
    let totalItems: Int

    /// Number of rows available for displaying items (terminal height - header - footer)
    let visibleRows: Int

    /// Creates a scroll engine with the given constraints.
    ///
    /// - Parameters:
    ///   - totalItems: Total number of items in the picker list
    ///   - visibleRows: Number of rows available for content display
    init(totalItems: Int, visibleRows: Int) {
        self.totalItems = max(0, totalItems)
        self.visibleRows = max(1, visibleRows)
    }
}


// MARK: - Scroll Calculation
extension ScrollEngine {
    /// Calculates the visible item range based on the active index.
    ///
    /// Uses centered scrolling to keep the active item in the middle of the viewport
    /// when possible. Handles edge cases at the top and bottom of the list.
    ///
    /// ## Algorithm Steps
    ///
    /// 1. **Clamp active index** — Ensure it's within valid range
    /// 2. **Calculate ideal start** — Center active item: `activeIndex - (visibleRows / 2)`
    /// 3. **Clamp to top** — If start < 0, start at 0
    /// 4. **Clamp to bottom** — If start would scroll past the end, adjust it
    /// 5. **Calculate end** — `start + visibleRows`, clamped to totalItems
    ///
    /// ## Edge Cases
    ///
    /// - **Empty list** — Returns (0, 0)
    /// - **All items fit** — Returns (0, totalItems)
    /// - **Near top** — Returns (0, visibleRows)
    /// - **Near bottom** — Returns (totalItems - visibleRows, totalItems)
    ///
    /// - Parameter activeIndex: The index of the currently active/focused item
    /// - Returns: Tuple of (startIndex, endIndex) for the visible slice
    func bounds(activeIndex: Int) -> (start: Int, end: Int) {
        // Handle empty list
        guard totalItems > 0 else {
            return (0, 0)
        }

        // Clamp active index to valid range
        let clamped = max(0, min(activeIndex, totalItems - 1))

        // Try to center the active item in the viewport
        let half = visibleRows / 2
        var start = clamped - half

        // Clamp start to top of list
        if start < 0 {
            start = 0
        }

        // Clamp start to prevent scrolling past the end
        // (ensure we always show visibleRows items when possible)
        let maxStart = max(0, totalItems - visibleRows)
        if start > maxStart {
            start = maxStart
        }

        // Calculate end index (exclusive, like array slicing)
        let end = min(totalItems, start + visibleRows)

        return (start, end)
    }

    /// Determines whether to show the up arrow scroll indicator.
    ///
    /// The up arrow indicates there are items above the currently visible range.
    ///
    /// - Parameter start: The start index of the visible range
    /// - Returns: `true` if items exist above the visible range
    func showScrollUp(start: Int) -> Bool {
        start > 0
    }

    /// Determines whether to show the down arrow scroll indicator.
    ///
    /// The down arrow indicates there are items below the currently visible range.
    ///
    /// - Parameter end: The end index (exclusive) of the visible range
    /// - Returns: `true` if items exist below the visible range
    func showScrollDown(end: Int) -> Bool {
        end < totalItems
    }
}
