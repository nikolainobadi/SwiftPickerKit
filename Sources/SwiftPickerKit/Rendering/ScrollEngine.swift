//
//  ScrollEngine.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct ScrollEngine {
    let totalItems: Int

    /// The number of items that can be displayed at once
    let displayableCount: Int

    init(totalItems: Int, displayableCount: Int) {
        self.totalItems = max(0, totalItems)
        self.displayableCount = max(1, displayableCount)
    }

    func bounds(activeIndex: Int) -> (start: Int, end: Int) {
        guard totalItems > 0 else { return (0, 0) }

        let half = displayableCount / 2

        let start = max(0, activeIndex - half)
        let end = min(totalItems, start + displayableCount)

        return (start, end)
    }

    func showScrollUp(start: Int) -> Bool {
        start > 0
    }

    func showScrollDown(end: Int) -> Bool {
        end < totalItems
    }
}
