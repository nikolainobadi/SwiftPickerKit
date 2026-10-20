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

// MARK: - Required Prompts
extension SelectionHandlerTests {
    @Test
    func `Interrupted required single selection throws an interrupted error`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            #expect(throws: PickerInterruptedError()) {
                _ = try sut.requiredSingleSelection(
                    prompt: "Pick one",
                    items: ["First", "Second"],
                    layout: .singleColumn,
                    newScreen: false,
                    showSelectedItemText: true
                )
            }
        }
    }

    @Test
    func `Interrupted required tree navigation throws an interrupted error`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            #expect(throws: PickerInterruptedError()) {
                _ = try sut.requiredTreeNavigation(
                    prompt: "Pick one",
                    root: makeTreeRoot(),
                    showPromptText: true,
                    showSelectedItemText: true
                )
            }
        }
    }

    @Test
    func `Interrupted flag hint single selection throws an interrupted error`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            #expect(throws: PickerInterruptedError()) {
                _ = try sut.requiredSingleSelection(
                    prompt: "Pick one",
                    items: ["First", "Second"],
                    flagHint: "--item",
                    layout: .singleColumn,
                    newScreen: false,
                    showSelectedItemText: true
                )
            }
        }
    }

    @Test
    func `Interrupted flag hint multi selection throws an interrupted error`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            #expect(throws: PickerInterruptedError()) {
                _ = try sut.requiredMultiSelection(
                    prompt: "Pick many",
                    items: ["First", "Second"],
                    flagHint: "--items",
                    layout: .singleColumn,
                    newScreen: false,
                    showSelectedItemText: true
                )
            }
        }
    }

    @Test
    func `Interrupted flag hint tree navigation throws an interrupted error`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            interruptOnFirstPoll(pickerInput)

            #expect(throws: PickerInterruptedError()) {
                _ = try sut.requiredTreeNavigation(
                    prompt: "Pick one",
                    root: makeTreeRoot(),
                    flagHint: "--path",
                    showPromptText: true,
                    showSelectedItemText: true
                )
            }
        }
    }

    @Test
    func `Quitting a required selection still throws selection cancelled`() {
        withIgnoredInterrupt {
            let (sut, pickerInput) = makeSUT()
            pickerInput.pressKey = true
            pickerInput.enqueueSpecialChar(.quit)

            #expect(throws: SwiftPickerError.selectionCancelled) {
                _ = try sut.requiredSingleSelection(
                    prompt: "Pick one",
                    items: ["First", "Second"],
                    layout: .singleColumn,
                    newScreen: false,
                    showSelectedItemText: true
                )
            }
        }
    }

    @Test
    func `Other pickers ignore an interrupt from an earlier SwiftPicker prompt`() {
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

            let nonInteractive = NonInteractivePicker(assumeYes: false)

            #expect(throws: SwiftPickerError.selectionCancelled) {
                _ = try nonInteractive.requiredSingleSelection(
                    prompt: "Pick one",
                    items: ["First", "Second"],
                    layout: .singleColumn,
                    newScreen: false,
                    showSelectedItemText: true
                )
            }
        }
    }
}

// MARK: - Wait For Termination
/// In production the wait never returns; these record the call and let it return, so the loop
/// then finishes as cancelled.
extension SelectionHandlerTests {
    @Test
    func `Interrupted single selection waits for termination when asked to`() {
        withIgnoredInterrupt {
            var waitCount = 0
            let (sut, pickerInput) = makeSUT(waitForTermination: { waitCount += 1 })
            interruptOnFirstPoll(pickerInput)

            _ = sut.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(waitCount == 1)
        }
    }

    @Test
    func `Interrupted multi selection waits for termination when asked to`() {
        withIgnoredInterrupt {
            var waitCount = 0
            let (sut, pickerInput) = makeSUT(waitForTermination: { waitCount += 1 })
            interruptOnFirstPoll(pickerInput)

            _ = sut.multiSelection(
                prompt: "Pick many",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(waitCount == 1)
        }
    }

    @Test
    func `Interrupted tree navigation waits for termination when asked to`() {
        withIgnoredInterrupt {
            var waitCount = 0
            let (sut, pickerInput) = makeSUT(waitForTermination: { waitCount += 1 })
            interruptOnFirstPoll(pickerInput)

            _ = sut.treeNavigation(
                prompt: "Pick one",
                root: makeTreeRoot(),
                showPromptText: true,
                showSelectedItemText: true
            )

            #expect(waitCount == 1)
        }
    }

    @Test
    func `Uninterrupted selection never waits`() {
        withIgnoredInterrupt {
            var waitCount = 0
            let (sut, pickerInput) = makeSUT(waitForTermination: { waitCount += 1 })
            pickerInput.pressKey = true
            pickerInput.enqueueSpecialChar(.enter)

            let result = sut.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(result == "First")
            #expect(waitCount == 0)
        }
    }

    @Test
    func `Quitting a selection never waits`() {
        withIgnoredInterrupt {
            var waitCount = 0
            let (sut, pickerInput) = makeSUT(waitForTermination: { waitCount += 1 })
            pickerInput.pressKey = true
            pickerInput.enqueueSpecialChar(.quit)

            _ = sut.singleSelection(
                prompt: "Pick one",
                items: ["First", "Second"],
                layout: .singleColumn,
                newScreen: false,
                showSelectedItemText: true
            )

            #expect(waitCount == 0)
        }
    }

    @Test
    func `Finish as cancelled behavior does not wait`() {
        let sut = SwiftPicker(interruptBehavior: .finishAsCancelled)

        #expect(sut.waitForTermination == nil)
    }

    @Test
    func `Default picker does not wait`() {
        let sut = SwiftPicker()

        #expect(sut.waitForTermination == nil)
    }

    @Test
    func `Wait for termination behavior installs a wait`() {
        let sut = SwiftPicker(interruptBehavior: .waitForTermination)

        #expect(sut.waitForTermination != nil)
    }
}

// MARK: - SUT
private extension SelectionHandlerTests {
    func makeSUT(waitForTermination: @escaping () -> Void) -> (SwiftPicker, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput, waitForTermination: waitForTermination)
        return (sut, pickerInput)
    }

    func makeSUT() -> (SwiftPicker, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let textInput = MockTextInput()
        let sut = SwiftPicker(textInput: textInput, pickerInput: pickerInput, waitForTermination: nil)
        return (sut, pickerInput)
    }

    func makeTreeRoot() -> TreeNavigationRoot<TreeTestItem> {
        let item = TestFactory.makeTreeItem(name: "Leaf")
        return TreeNavigationRoot(displayName: "Root", children: [item])
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
