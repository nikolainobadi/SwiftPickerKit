//
//  PickerHeaderRendererTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

import Testing
@testable import SwiftPickerKit

struct PickerHeaderRendererTests {
    @Test
    func `Starting values empty`() {
        let (_, pickerInput) = makeSUT()

        #expect(pickerInput.writtenText.isEmpty)
        #expect(pickerInput.moveToCalls.isEmpty)
        #expect(pickerInput.cursorMovedToHome == false)
    }

    @Test
    func `Centers header content with divider`() {
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

    @Test
    func `Shows selected item details between dividers`() {
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

    @Test
    func `Truncates prompt and detail lines beyond available width`() {
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

    @Test
    func `Hides prompt text when requested`() {
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
        let hasDivider = pickerInput.writtenText.contains {
            let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && trimmed.allSatisfy { $0 == "─" }
        }
        #expect(hasDivider == false)
    }

    @Test
    func `Hides selected item section when requested`() {
        let screenWidth = 12
        let (sut, pickerInput) = makeSUT()

        let height = sut.renderHeader(
            prompt: "Prompt",
            topLineText: "Header",
            selectedItem: "Choice",
            selectedDetailLines: ["Detail"],
            showSelectedItemText: false,
            screenWidth: screenWidth
        )

        #expect(height == 5)
        #expect(pickerInput.writtenText.contains { $0.contains("Selected:") } == false)
        #expect(pickerInput.writtenText.contains { $0.contains("Detail") } == false)
    }
}


// MARK: - SUT
private extension PickerHeaderRendererTests {
    func makeSUT(dividerStyle: PickerDividerStyle = .single) -> (PickerHeaderRenderer, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = PickerHeaderRenderer(pickerInput: pickerInput, dividerStyle: dividerStyle)
        return (sut, pickerInput)
    }
}
