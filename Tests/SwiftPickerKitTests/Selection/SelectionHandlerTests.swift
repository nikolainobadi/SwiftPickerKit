//
//  SelectionHandlerTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation
import Testing
@testable import SwiftPickerKit

/// The host ignores SIGINT in these tests (as a `DispatchSource`-based host would), so the
/// picker's handler restores the terminal and leaves the process running.
@Suite(.signalState)
struct SelectionHandlerTests {
    @Test
    func `Interrupted single selection finishes as if the user quit`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            let result = sut.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(result == nil)
        }
    }

    @Test
    func `Interrupted multi selection finishes with nothing selected`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            let result = sut.multiSelection(
                prompt: "Pick many",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(result.isEmpty)
        }
    }

    @Test
    func `Interrupted picker restores the terminal`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            _ = sut.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(pickerInput.didExitAlternativeScreen)
            #expect(pickerInput.didEnableNormalInput)
        }
    }

    @Test
    func `Next picker is not cancelled by an earlier interrupt`() {
        withIgnoredInterrupt {
            let (sut, interruptedInput) = makeSUT()
            interruptOnFirstPoll(interruptedInput)
            _ = sut.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            let (nextSUT, nextInput) = makeSUT()
            nextInput.pressKey = true
            nextInput.enqueueSpecialChar(.enter)

            let result = nextSUT.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(result == "First")
        }
    }
}


// MARK: - SUT
private extension SelectionHandlerTests {
    func makeSUT() -> (SwiftPicker, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput)
        return (sut, pickerInput)
    }
}


// MARK: - Helpers
private extension SelectionHandlerTests {
    /// Delivers SIGINT the first time the loop polls for a key. If the loop ignored the
    /// interrupt, later polls press Space then Enter — selecting "First" in both single and
    /// multi selection — so a regression fails instead of hanging.
    func interruptOnFirstPoll(_ pickerInput: MockPickerInput) {
        var pollCount = 0
        pickerInput.enqueueSpecialChar(.space)
        pickerInput.enqueueSpecialChar(.enter)
        pickerInput.onKeyPressed = { [weak pickerInput] in
            pollCount += 1

            if pollCount == 1 {
                SignalHandler.handle(signal: SIGINT, info: nil, context: nil)
            } else {
                pickerInput?.pressKey = true
            }
        }
    }

    func withIgnoredInterrupt(_ body: () -> Void) {
        var originalInterrupt = sigaction()
        var ignore = sigaction()
        ignore.__sigaction_u.__sa_handler = SIG_IGN
        sigemptyset(&ignore.sa_mask)
        ignore.sa_flags = 0
        sigaction(SIGINT, &ignore, &originalInterrupt)

        defer {
            sigaction(SIGINT, &originalInterrupt, nil)
        }

        body()
    }
}
