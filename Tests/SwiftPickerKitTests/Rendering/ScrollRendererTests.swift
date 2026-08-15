//
//  ScrollRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct ScrollRendererTests {
    @Test
    func `Starting values empty`() {
        let (_, pickerInput) = makeSUT()
        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
    }

    @Test
    func `Displays up arrow at specified row position`() {
        let row = 5
        let (sut, pickerInput) = makeSUT()

        sut.renderUpArrow(at: row)

        #expect(pickerInput.moveToCalls.count == 1)
        #expect(pickerInput.moveToCalls[0].row == row)
        #expect(pickerInput.moveToCalls[0].col == 0)
        #expect(pickerInput.writtenText.count == 1)
        #expect(pickerInput.writtenText[0].contains("↑"))
    }

    @Test
    func `Displays down arrow at specified row position`() {
        let row = 10
        let (sut, pickerInput) = makeSUT()

        sut.renderDownArrow(at: row)

        #expect(pickerInput.moveToCalls.count == 1)
        #expect(pickerInput.moveToCalls[0].row == row)
        #expect(pickerInput.moveToCalls[0].col == 0)
        #expect(pickerInput.writtenText.count == 1)
        #expect(pickerInput.writtenText[0].contains("↓"))
    }

    @Test
    func `Positions up arrow at column zero for any row`() {
        let (sut, pickerInput) = makeSUT()

        sut.renderUpArrow(at: 0)
        sut.renderUpArrow(at: 15)
        sut.renderUpArrow(at: 30)

        #expect(pickerInput.moveToCalls.allSatisfy { $0.col == 0 })
    }

    @Test
    func `Positions down arrow at column zero for any row`() {
        let (sut, pickerInput) = makeSUT()

        sut.renderDownArrow(at: 1)
        sut.renderDownArrow(at: 20)
        sut.renderDownArrow(at: 45)

        #expect(pickerInput.moveToCalls.allSatisfy { $0.col == 0 })
    }

    @Test
    func `Renders multiple arrows at different positions`() {
        let (sut, pickerInput) = makeSUT()

        sut.renderUpArrow(at: 3)
        sut.renderDownArrow(at: 8)

        #expect(pickerInput.moveToCalls.count == 2)
        #expect(pickerInput.moveToCalls[0].row == 3)
        #expect(pickerInput.moveToCalls[1].row == 8)
        #expect(pickerInput.writtenText.count == 2)
        #expect(pickerInput.writtenText[0].contains("↑"))
        #expect(pickerInput.writtenText[1].contains("↓"))
    }

    @Test
    func `Handles zero row position for up arrow`() {
        let (sut, pickerInput) = makeSUT()

        sut.renderUpArrow(at: 0)

        #expect(pickerInput.moveToCalls[0].row == 0)
        #expect(pickerInput.moveToCalls[0].col == 0)
    }

    @Test
    func `Handles zero row position for down arrow`() {
        let (sut, pickerInput) = makeSUT()

        sut.renderDownArrow(at: 0)

        #expect(pickerInput.moveToCalls[0].row == 0)
        #expect(pickerInput.moveToCalls[0].col == 0)
    }
}


// MARK: - SUT
private extension ScrollRendererTests {
    func makeSUT() -> (ScrollRenderer, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = ScrollRenderer(pickerInput: pickerInput)
        return (sut, pickerInput)
    }
}
