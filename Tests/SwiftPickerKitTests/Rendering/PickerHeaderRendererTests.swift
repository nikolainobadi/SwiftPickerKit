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
            selectedDetailLines: [],
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
        let details = [PickerDetailLine(text: "First detail", kind: .metadataDetail), PickerDetailLine(text: "Second detail", kind: .metadataDetail)]
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
            selectedDetailLines: [PickerDetailLine(text: longDetail, kind: .metadataDetail)],
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
            selectedDetailLines: [],
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
            selectedDetailLines: [PickerDetailLine(text: "Detail", kind: .metadataDetail)],
            showSelectedItemText: false,
            screenWidth: screenWidth
        )

        #expect(height == 5)
        #expect(pickerInput.writtenText.contains { $0.contains("Selected:") } == false)
        #expect(pickerInput.writtenText.contains { $0.contains("Detail") } == false)
    }
    @Test
    func `Styles detail lines from the theme by kind`() {
        let (sut, pickerInput) = makeSUT(dividerStyle: .single)
        let details = [
            PickerDetailLine(text: "Sub", kind: .subtitle),
            PickerDetailLine(text: "Info", kind: .metadataDetail),
            PickerDetailLine(text: "Empty", kind: .emptyFolderMessage)
        ]

        _ = sut.renderHeader(prompt: "Prompt", topLineText: "Top", selectedItem: "Item", selectedDetailLines: details, showSelectedItemText: true, showPromptText: true, screenWidth: 9)

        #expect(pickerInput.writtenText.contains("   \u{1B}[38;5;240mSub\u{1B}[0m"))
        #expect(pickerInput.writtenText.contains("  \u{1B}[38;5;244mInfo\u{1B}[0m"))
        #expect(pickerInput.writtenText.contains("  \u{1B}[38;5;208mEmpty\u{1B}[0m"))
    }

    @Test
    func `Centers the selected line by its visible width`() {
        let (sut, pickerInput) = makeSUT(dividerStyle: .single)

        _ = sut.renderHeader(prompt: "Prompt", topLineText: "Top", selectedItem: "A", selectedDetailLines: [], showSelectedItemText: true, showPromptText: true, screenWidth: 15)

        #expect(pickerInput.writtenText.contains("  \u{1B}[38;5;51mSelected: A\u{1B}[0m"))
    }
}

// MARK: - SUT
private extension PickerHeaderRendererTests {
    func makeSUT(dividerStyle: PickerDividerStyle = .single) -> (PickerHeaderRenderer, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = PickerHeaderRenderer(pickerInput: pickerInput, dividerStyle: dividerStyle, theme: .standard, styler: PickerStyler(colorEnabled: true))
        return (sut, pickerInput)
    }
}
