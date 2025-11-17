//
//  ScrollEngine.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct ScrollEngine {
    let totalItems: Int
    let visibleRows: Int   // number of rows available for scrollable content

    init(totalItems: Int, visibleRows: Int) {
        self.totalItems = max(0, totalItems)
        self.visibleRows = max(1, visibleRows)
    }

    func bounds(activeIndex: Int) -> (start: Int, end: Int) {
        guard totalItems > 0 else { return (0, 0) }

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

    func showScrollUp(start: Int) -> Bool {
        start > 0
    }

    func showScrollDown(end: Int) -> Bool {
        end < totalItems
    }
}
