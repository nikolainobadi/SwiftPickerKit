import Testing
@testable import SwiftPickerKit

struct TreeNavigationRendererStylingTests {
    @Test
    func `Draws a styled node in its own style`() {
        let items = [makeNode(name: "Broken", displayStyle: .failure, children: []), makeNode(name: "Other", displayStyle: nil, children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        state.activeIndex = 1
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(visibleRowCount: 20), input: pickerInput, screenWidth: 80)

        #expect(pickerInput.writtenText.contains("\u{1B}[1;31m  Broken\u{1B}[0m"))
    }

    @Test
    func `Dims rows in the unfocused column and keeps their color`() {
        let child = makeNode(name: "Child", displayStyle: nil, children: [])
        let items = [makeNode(name: "Parent", displayStyle: nil, children: [child]), makeNode(name: "Sibling", displayStyle: .failure, children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        state.descendIntoChildIfPossible()
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(visibleRowCount: 20), input: pickerInput, screenWidth: 80)

        #expect(pickerInput.writtenText.contains("\u{1B}[1;2;31m  Sibling\u{1B}[0m"))
    }

    @Test
    func `Truncates the breadcrumb before styling it`() {
        let child = makeNode(name: "AVeryLongChildFolderName", displayStyle: nil, children: [])
        let items = [makeNode(name: "AVeryLongParentFolderName", displayStyle: nil, children: [child])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        state.descendIntoChildIfPossible()
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(visibleRowCount: 20), input: pickerInput, screenWidth: 20)

        let breadcrumb = PickerTextFormatter.truncate(state.breadcrumbPath(), maxWidth: 20)
        #expect(pickerInput.writtenText.contains("\u{1B}[94m\(breadcrumb)\u{1B}[0m"))
    }

    @Test
    func `Draws rows without color but keeps underline when color is disabled`() {
        let items = [makeNode(name: "Broken", displayStyle: .failure, children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        let (sut, pickerInput) = makeSUT(colorEnabled: false)

        sut.render(items: items, state: state, context: makeContext(visibleRowCount: 20), input: pickerInput, screenWidth: 80)

        #expect(pickerInput.writtenText.contains("\u{1B}[1;4m  Broken\u{1B}[0m"))
        #expect(pickerInput.writtenText.contains { $0.contains("[31m") || $0.contains("38;5") } == false)
    }
}

// MARK: - Helpers
private extension TreeNavigationRendererStylingTests {
    func makeNode(name: String, displayStyle: PickerTextStyle?, children: [TreeNode<String>]) -> TreeNode<String> {
        return TreeNode(name: name, value: name, hasChildren: !children.isEmpty, isSelectable: true, metadata: nil, displayStyle: displayStyle, loadChildren: { children })
    }

    func makeContext(visibleRowCount: Int) -> ScrollRenderContext {
        return ScrollRenderContext(startIndex: 0, endIndex: 2, listStartRow: 0, visibleRowCount: visibleRowCount)
    }
}

// MARK: - SUT
private extension TreeNavigationRendererStylingTests {
    func makeSUT(colorEnabled: Bool) -> (TreeNavigationRenderer<TreeNode<String>>, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = TreeNavigationRenderer<TreeNode<String>>(theme: .standard, styler: PickerStyler(colorEnabled: colorEnabled))
        return (sut, pickerInput)
    }
}
