//
//  ScrollEngine.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Computes the visible slice of a list and whether scroll arrows are needed.
///
/// Keeps the active item centered where possible, pinning to the top or bottom near the ends.
struct ScrollEngine {
    let totalItems: Int

    /// Rows available for items; clamped to at least 1.
    let visibleRows: Int

    init(totalItems: Int, visibleRows: Int) {
        self.totalItems = max(0, totalItems)
        self.visibleRows = max(1, visibleRows)
    }
}

// MARK: - Scroll Calculation
extension ScrollEngine {
    /// Returns the visible range centered on `activeIndex` (clamped into range).
    ///
    /// The window never scrolls past the end, so it stays full whenever `totalItems >= visibleRows`.
    ///
    /// - Returns: `(start, end)` with `end` exclusive; `(0, 0)` for an empty list.
    func bounds(activeIndex: Int) -> (start: Int, end: Int) {
        guard totalItems > 0 else {
            return (0, 0)
        }

        let clamped = max(0, min(activeIndex, totalItems - 1))

        let half = visibleRows / 2
        var start = clamped - half

        if start < 0 {
            start = 0
        }

        let maxStart = max(0, totalItems - visibleRows)
        if start > maxStart {
            start = maxStart
        }

        let end = min(totalItems, start + visibleRows)

        return (start, end)
    }

    /// Whether items exist above the visible range.
    func showScrollUp(start: Int) -> Bool {
        return start > 0
    }

    /// Whether items exist below the visible range (`end` is exclusive).
    func showScrollDown(end: Int) -> Bool {
        return end < totalItems
    }
}
