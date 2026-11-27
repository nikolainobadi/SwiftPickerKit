import Testing
@testable import SwiftPickerKit

struct TreeNavigationRendererSegmentTests {
    @Test
    func `Draws the icon and then each segment in its own style`() {
        let items = [makeNode(name: "a", segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], children: []), makeNode(name: "b", segments: [], children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        state.activeIndex = 1
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(), input: pickerInput, screenWidth: 80)

        #expect(pickerInput.writtenText.joined().contains("\u{1B}[38;5;250m  \u{1B}[0m\u{1B}[38;5;250mjob \u{1B}[0m\u{1B}[1;31mfailed\u{1B}[0m"))
    }

    @Test
    func `Underlines every segment on the focused active row`() {
        let items = [makeNode(name: "a", segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(), input: pickerInput, screenWidth: 80)

        #expect(pickerInput.writtenText.joined().contains("\u{1B}[4;38;5;250mjob \u{1B}[0m\u{1B}[1;4;31mfailed\u{1B}[0m"))
    }

    @Test
    func `Dims every segment in the unfocused column`() {
        let child = makeNode(name: "child", segments: [.init(text: "child", style: nil)], children: [])
        let items = [makeNode(name: "parent", segments: [.init(text: "parent", style: nil)], children: [child]), makeNode(name: "b", segments: [.init(text: "job ", style: nil), .init(text: "failed", style: .failure)], children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        state.descendIntoChildIfPossible()
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(), input: pickerInput, screenWidth: 80)

        #expect(pickerInput.writtenText.joined().contains("\u{1B}[2;38;5;250mjob \u{1B}[0m\u{1B}[1;2;31mfailed\u{1B}[0m"))
    }

    @Test
    func `Truncates across segments before styling them`() {
        let items = [makeNode(name: "a", segments: [.init(text: "job ", style: nil), .init(text: "failed-badly", style: .failure)], children: [])]
        let state = TreeNavigationState(rootItems: items, prompt: "Test")
        let (sut, pickerInput) = makeSUT(colorEnabled: true)

        sut.render(items: items, state: state, context: makeContext(), input: pickerInput, screenWidth: 12)

        #expect(pickerInput.writtenText.joined().contains("\u{1B}[4;38;5;250mjob \u{1B}[0m\u{1B}[1;4;31mf…\u{1B}[0m"))
    }
}

// MARK: - Helpers
private extension TreeNavigationRendererSegmentTests {
    func makeNode(name: String, segments: [PickerTextSegment], children: [SegmentedNode]) -> SegmentedNode {
        return SegmentedNode(name: name, displaySegments: segments, children: children)
    }

    func makeContext() -> ScrollRenderContext {
        return ScrollRenderContext(startIndex: 0, endIndex: 2, listStartRow: 0, visibleRowCount: 20)
    }
}

// MARK: - SUT
private extension TreeNavigationRendererSegmentTests {
    func makeSUT(colorEnabled: Bool) -> (TreeNavigationRenderer<SegmentedNode>, MockPickerInput) {
        let pickerInput = MockPickerInput()
        let sut = TreeNavigationRenderer<SegmentedNode>(theme: .standard, styler: PickerStyler(colorEnabled: colorEnabled))
        return (sut, pickerInput)
    }
}

// MARK: - Test Items
private struct SegmentedNode: TreeNodePickerItem, SegmentedPickerItem {
    let name: String
    let displaySegments: [PickerTextSegment]
    let children: [SegmentedNode]

    var displayName: String { name }
    var hasChildren: Bool { !children.isEmpty }
    var metadata: TreeNodeMetadata? { nil }
    var isSelectable: Bool { true }

    func loadChildren() -> [SegmentedNode] {
        return children
    }
}
