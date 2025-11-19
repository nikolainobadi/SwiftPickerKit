//
//  MockPickerInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

@testable import SwiftPickerKit

final class MockPickerInput: PickerInput {
    var pressKey = false

    private enum Event {
        case special(SpecialChar)
        case direction(Direction)
    }

    private var events: [Event] = []

    private(set) var cursorMovedToHome = false
    private(set) var didEnterAlternativeScreen = false
    private(set) var didExitAlternativeScreen = false
    private(set) var didEnableNormalInput = false
    private(set) var writtenText: [String] = []
    private(set) var moveToCalls: [(row: Int, col: Int)] = []

    private let screenSize: (rows: Int, cols: Int)

    init(screenSize: (rows: Int, cols: Int) = (40, 100)) {
        self.screenSize = screenSize
    }

    func enqueueSpecialChar(_ specialChar: SpecialChar) {
        events.append(.special(specialChar))
    }

    func enqueueDirectionKey(_ direction: Direction) {
        events.append(.direction(direction))
    }
}


// MARK: - PickerInput
extension MockPickerInput {
    func cursorOff() {}
    func moveRight() {}

    func moveToHome() {
        cursorMovedToHome = true
    }

    func clearBuffer() {}
    func clearScreen() {}

    func enableNormalInput() {
        didEnableNormalInput = true
    }

    func keyPressed() -> Bool {
        pressKey && !events.isEmpty
    }

    func write(_ text: String) {
        writtenText.append(text)
    }

    func exitAlternativeScreen() {
        didExitAlternativeScreen = true
    }

    func enterAlternativeScreen() {
        didEnterAlternativeScreen = true
    }

    func moveTo(_ row: Int, _ col: Int) {
        moveToCalls.append((row, col))
    }

    func readDirectionKey() -> Direction? {
        guard let next = events.first else { return nil }
        switch next {
        case .direction(let direction):
            events.removeFirst()
            return direction
        case .special:
            return nil
        }
    }

    func readSpecialChar() -> SpecialChar? {
        guard let next = events.first else { return nil }
        switch next {
        case .special(let char):
            events.removeFirst()
            return char
        case .direction:
            return nil
        }
    }

    func readCursorPos() -> (row: Int, col: Int) {
        (0, 0)
    }

    func readScreenSize() -> (rows: Int, cols: Int) {
        screenSize
    }

}
