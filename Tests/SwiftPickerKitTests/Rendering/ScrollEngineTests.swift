//
//  ScrollEngineTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct ScrollEngineTests {
    @Test("Starting values set to normalized minimums")
    func startingValuesSetToNormalizedMinimums() {
        let sut = makeSUT(totalItems: -5, visibleRows: -3)

        #expect(sut.totalItems == 0)
        #expect(sut.visibleRows == 1)
    }

    @Test("Preserves positive initialization values")
    func preservesPositiveInitializationValues() {
        let totalItems = 20
        let visibleRows = 10
        let sut = makeSUT(totalItems: totalItems, visibleRows: visibleRows)

        #expect(sut.totalItems == totalItems)
        #expect(sut.visibleRows == visibleRows)
    }

    @Test("Clamps total items to zero when negative")
    func clampsTotalItemsToZeroWhenNegative() {
        let sut = makeSUT(totalItems: -10, visibleRows: 5)

        #expect(sut.totalItems == 0)
    }

    @Test("Clamps visible rows to one when zero or negative")
    func clampsVisibleRowsToOneWhenZeroOrNegative() {
        let sutZero = makeSUT(totalItems: 10, visibleRows: 0)
        let sutNegative = makeSUT(totalItems: 10, visibleRows: -5)

        #expect(sutZero.visibleRows == 1)
        #expect(sutNegative.visibleRows == 1)
    }

    @Test("Returns empty bounds when no items available")
    func returnsEmptyBoundsWhenNoItemsAvailable() {
        let sut = makeSUT(totalItems: 0, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: 0)

        #expect(bounds.start == 0)
        #expect(bounds.end == 0)
    }

    @Test("Calculates bounds with active index at start")
    func calculatesBoundsWithActiveIndexAtStart() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: 0)

        #expect(bounds.start == 0)
        #expect(bounds.end == 10)
    }

    @Test("Calculates bounds with active index in middle")
    func calculatesBoundsWithActiveIndexInMiddle() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: 10)

        #expect(bounds.start == 5)
        #expect(bounds.end == 15)
    }

    @Test("Calculates bounds with active index at end")
    func calculatesBoundsWithActiveIndexAtEnd() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: 19)

        #expect(bounds.start == 10)
        #expect(bounds.end == 20)
    }

    @Test("Clamps active index when beyond total items")
    func clampsActiveIndexWhenBeyondTotalItems() {
        let sut = makeSUT(totalItems: 10, visibleRows: 5)

        let bounds = sut.bounds(activeIndex: 20)

        #expect(bounds.start == 5)
        #expect(bounds.end == 10)
    }

    @Test("Clamps negative active index to zero")
    func clampsNegativeActiveIndexToZero() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: -5)

        #expect(bounds.start == 0)
        #expect(bounds.end == 10)
    }

    @Test("Shows all items when total items fit within visible rows")
    func showsAllItemsWhenTotalItemsFitWithinVisibleRows() {
        let sut = makeSUT(totalItems: 5, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: 2)

        #expect(bounds.start == 0)
        #expect(bounds.end == 5)
    }

    @Test("Centers active item in visible window when scrolling")
    func centersActiveItemInVisibleWindowWhenScrolling() {
        let sut = makeSUT(totalItems: 100, visibleRows: 10)

        let bounds = sut.bounds(activeIndex: 50)

        #expect(bounds.start == 45)
        #expect(bounds.end == 55)
    }

    @Test("Indicates scrolling up is not available when at start")
    func indicatesScrollingUpIsNotAvailableWhenAtStart() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let canScrollUp = sut.showScrollUp(start: 0)

        #expect(!canScrollUp)
    }

    @Test("Indicates scrolling up is available when past start")
    func indicatesScrollingUpIsAvailableWhenPastStart() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let canScrollUp = sut.showScrollUp(start: 5)

        #expect(canScrollUp)
    }

    @Test("Indicates scrolling down is not available when at end")
    func indicatesScrollingDownIsNotAvailableWhenAtEnd() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let canScrollDown = sut.showScrollDown(end: 20)

        #expect(!canScrollDown)
    }

    @Test("Indicates scrolling down is available when before end")
    func indicatesScrollingDownIsAvailableWhenBeforeEnd() {
        let sut = makeSUT(totalItems: 20, visibleRows: 10)

        let canScrollDown = sut.showScrollDown(end: 15)

        #expect(canScrollDown)
    }

    @Test("Maintains window size when scrolling through items")
    func maintainsWindowSizeWhenScrollingThroughItems() {
        let sut = makeSUT(totalItems: 50, visibleRows: 10)

        let bounds1 = sut.bounds(activeIndex: 10)
        let bounds2 = sut.bounds(activeIndex: 25)
        let bounds3 = sut.bounds(activeIndex: 40)

        #expect(bounds1.end - bounds1.start == 10)
        #expect(bounds2.end - bounds2.start == 10)
        #expect(bounds3.end - bounds3.start == 10)
    }
}


// MARK: - Helpers
private extension ScrollEngineTests {
    func makeSUT(totalItems: Int, visibleRows: Int) -> ScrollEngine {
        ScrollEngine(totalItems: totalItems, visibleRows: visibleRows)
    }
}
