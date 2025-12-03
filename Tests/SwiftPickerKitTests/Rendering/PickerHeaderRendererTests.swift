//
//  PickerHeaderRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct PickerHeaderRendererTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, pickerInput) = makeSUT()

        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
        #expect(pickerInput.cursorMovedToHome == false)
    }

    @Test("Centers header content with divider")
    func centersHeaderContentWithDivider() {
        let screenWidth = 10
        let (sut, pickerInput) = makeSUT(dividerStyle: .single)

        let height = sut.renderHeader(
            prompt: "Prompt",
            topLineText: "Header",
            selectedItem: nil,
            screenWidth: screenWidth
        )

        #expect(height == 5)
        #expect(pickerInput.cursorMovedToHome)
        #expect(pickerInput.writtenText == [
            "  Header",
            "\n",
            String(repeating: "─", count: screenWidth) + "\n",
            "  Prompt",
            "\n",
            "\n",
            "\n"
        ])
    }

    @Test("Shows selected item details between dividers")
    func showsSelectedItemDetailsBetweenDividers() {
        let screenWidth = 12
        let details = ["First detail", "Second detail"]
        let (sut, pickerInput) = makeSUT(dividerStyle: .double)

        let height = sut.renderHeader(
            prompt: "Choose one",
            topLineText: "Picker",
            selectedItem: "Choice",
            selectedDetailLines: details,
            screenWidth: screenWidth
        )

        let dividerLine = String(repeating: "=", count: screenWidth) + "\n"
        let dividerWrites = pickerInput.writtenText.filter { $0 == dividerLine }

        #expect(height == 11)
        #expect(dividerWrites.count == 3)
        #expect(pickerInput.writtenText.contains { $0.contains("Selected: Choice") })
    }

    @Test("Truncates prompt and detail lines beyond available width")
    func truncatesPromptAndDetailLinesBeyondAvailableWidth() {
        let screenWidth = 6
        let longPrompt = "prompt-long"
        let longDetail = "detail-long"
        let (sut, pickerInput) = makeSUT()

        _ = sut.renderHeader(
            prompt: longPrompt,
            topLineText: "Top",
            selectedItem: "Item",
            selectedDetailLines: [longDetail],
            screenWidth: screenWidth
        )

        #expect(pickerInput.writtenText.contains { $0.contains("pro…") })
        #expect(pickerInput.writtenText.contains { $0.contains("det…") })
    }

    @Test("Hides prompt text when requested")
    func hidesPromptTextWhenRequested() {
        let screenWidth = 10
        let (sut, pickerInput) = makeSUT()

        let height = sut.renderHeader(
            prompt: "Hidden prompt",
            topLineText: "Header",
            selectedItem: nil,
            showPromptText: false,
            screenWidth: screenWidth
        )

        #expect(height == 3)
        #expect(pickerInput.writtenText.contains { $0.contains("Hidden prompt") } == false)
        let hasDivider = pickerInput.writtenText.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).allSatisfy { $0 == "─" } }
        #expect(hasDivider == false)
    }
}


// MARK: - Helpers
private extension PickerHeaderRendererTests {
    func makeSUT(dividerStyle: PickerDividerStyle = .single) -> (PickerHeaderRenderer, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = PickerHeaderRenderer(pickerInput: pickerInput, dividerStyle: dividerStyle)
        return (sut, pickerInput)
    }
}
