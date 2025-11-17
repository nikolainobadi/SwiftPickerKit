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

        // Clamp active index
        let clamped = max(0, min(activeIndex, totalItems - 1))

        // Center active item when possible
        let half = visibleRows / 2
        var start = clamped - half

        // Clamp start
        if start < 0 { start = 0 }
        if start > max(0, totalItems - visibleRows) {
            start = max(0, totalItems - visibleRows)
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

struct ScrollLayout {
    let rows: Int
    let headerHeight: Int
    let footerHeight: Int
    
    var availableListRows: Int {
        rows - headerHeight - footerHeight
    }
}

struct ScrollRenderContext {
    let startIndex: Int
    let endIndex: Int
    let visibleRowCount: Int
    let listStartRow: Int
    let showUpArrow: Bool
    let showDownArrow: Bool
}

protocol ContentRenderer {
    associatedtype Item: DisplayablePickerItem
    func render(
        items: [Item],
        state: SelectionState<Item>,
        context: ScrollRenderContext,
        using input: PickerInput,
        screenWidth: Int
    )
}
