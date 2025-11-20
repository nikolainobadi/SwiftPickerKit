//
//  TreeNavigationStateTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 04/09/24.
//

import Testing
@testable import SwiftPickerKit

struct TreeNavigationStateTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let prompt = "Prompt"
        let roots = TestFactory.makeTreeItems(names: ["Root 1", "Root 2"])
        let (sut, _) = makeSUT(rootItems: roots, prompt: prompt)

        #expect(sut.prompt == prompt)
        #expect(sut.activeIndex == 0)
        #expect(sut.options.count == roots.count)
        #expect(sut.currentItems.map(\.displayName) == roots.map(\.displayName))
        #expect(sut.topLineText == "Tree Navigation")
        #expect(sut.bottomLineText.contains("Arrows"))
        #expect(sut.selectedDetailLines.isEmpty)
    }

    @Test("Clamps active index within current level bounds")
    func clampsActiveIndexWithinCurrentLevelBounds() {
        let roots = TestFactory.makeTreeItems(names: ["Root 1", "Root 2"])
        let (sut, _) = makeSUT(rootItems: roots)

        sut.activeIndex = 5

        #expect(sut.activeIndex == roots.count - 1)
    }

    @Test("Descends into child when children exist")
    func descendsIntoChildWhenChildrenExist() {
        let children = TestFactory.makeTreeItems(names: ["Child 1", "Child 2"])
        let roots = [TestFactory.makeTreeItem(name: "Root", children: children)]
        let (sut, _) = makeSUT(rootItems: roots)

        sut.descendIntoChildIfPossible()

        #expect(sut.currentItems.map(\.displayName) == children.map(\.displayName))
        #expect(sut.activeIndex == 0)
        #expect(sut.isEmptyHint(level: 0, index: 0) == false)
    }

    @Test("Shows empty folder hint when child list is empty")
    func showsEmptyFolderHintWhenChildListIsEmpty() {
        let roots = [TestFactory.makeTreeItem(name: "Empty", children: [], hasChildren: true)]
        let (sut, _) = makeSUT(rootItems: roots)

        sut.descendIntoChildIfPossible()

        #expect(sut.isEmptyHint(level: 0, index: 0))
        #expect(sut.selectedDetailLines.contains { $0.contains("'Empty' is empty") })
    }

    @Test("Clears empty folder hint when active selection changes")
    func clearsEmptyFolderHintWhenActiveSelectionChanges() {
        let roots = [
            TestFactory.makeTreeItem(name: "Empty", children: [], hasChildren: true),
            TestFactory.makeTreeItem(name: "Other")
        ]
        let (sut, _) = makeSUT(rootItems: roots)

        sut.descendIntoChildIfPossible()
        sut.activeIndex = 1

        #expect(sut.isEmptyHint(level: 0, index: 0) == false)
        #expect(sut.selectedDetailLines.isEmpty)
    }

    @Test("Ascends to parent and restores previous level")
    func ascendsToParentAndRestoresPreviousLevel() {
        let grandChildren = TestFactory.makeTreeItems(names: ["Grandchild"])
        let children = [TestFactory.makeTreeItem(name: "Child", children: grandChildren)]
        let roots = [TestFactory.makeTreeItem(name: "Root", children: children)]
        let (sut, _) = makeSUT(rootItems: roots)

        sut.descendIntoChildIfPossible()
        sut.descendIntoChildIfPossible()
        sut.ascendToParent()

        #expect(sut.currentItems.map(\.displayName) == children.map(\.displayName))
        #expect(sut.activeIndex == 0)
        #expect(sut.isEmptyHint(level: 1, index: 0) == false)
    }

    @Test("Builds breadcrumb path from current navigation stack")
    func buildsBreadcrumbPathFromCurrentNavigationStack() {
        let children = TestFactory.makeTreeItems(names: ["Child 1", "Child 2"])
        let roots = [
            TestFactory.makeTreeItem(name: "First"),
            TestFactory.makeTreeItem(name: "Second", children: children)
        ]
        let (sut, _) = makeSUT(rootItems: roots)

        sut.activeIndex = 1
        sut.descendIntoChildIfPossible()

        #expect(sut.breadcrumbPath() == "Second ▸ Child 1")
    }

    @Test("Builds detail lines from item metadata")
    func buildsDetailLinesFromItemMetadata() {
        let metadata = TestFactory.makeTreeMetadata(subtitle: "Subtitle", detailLines: ["Line 1", "Line 2"])
        let roots = [TestFactory.makeTreeItem(name: "Root", metadata: metadata)]
        let (sut, _) = makeSUT(rootItems: roots)

        let details = sut.selectedDetailLines

        #expect(details.contains(metadata.subtitle?.foreColor(240) ?? ""))
        #expect(details.contains("Line 1".foreColor(244)))
        #expect(details.contains("Line 2".foreColor(244)))
    }
}


// MARK: - SUT
private extension TreeNavigationStateTests {
    func makeSUT(rootItems: [TreeTestItem], prompt: String = "Prompt", fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (TreeNavigationState<TreeTestItem>, [TreeTestItem]) {
        let sut = TreeNavigationState(rootItems: rootItems, prompt: prompt)
        return (sut, rootItems)
    }
}


// MARK: - Test Factory
private extension TestFactory {
    static func makeTreeItems(names: [String], children: [[TreeTestItem]] = [], metadata: [TreeNodeMetadata?] = []) -> [TreeTestItem] {
        names.enumerated().map { index, name in
            let childItems = children.indices.contains(index) ? children[index] : []
            let itemMetadata = metadata.indices.contains(index) ? metadata[index] : nil
            return makeTreeItem(name: name, children: childItems, metadata: itemMetadata)
        }
    }

    static func makeTreeItem(name: String, children: [TreeTestItem] = [], hasChildren: Bool? = nil, metadata: TreeNodeMetadata? = nil) -> TreeTestItem {
        return .init(
            name: name,
            children: children,
            metadata: metadata,
            hasChildrenValue: hasChildren ?? !children.isEmpty
        )
    }

    static func makeTreeMetadata(subtitle: String? = nil, detailLines: [String] = []) -> TreeNodeMetadata {
        return .init(subtitle: subtitle, detailLines: detailLines)
    }
}


// MARK: - Dependencies
private struct TreeTestItem: TreeNodePickerItem {
    let name: String
    let children: [TreeTestItem]
    let metadata: TreeNodeMetadata?
    let hasChildrenValue: Bool

    var hasChildren: Bool { hasChildrenValue }

    var displayName: String { name }

    func loadChildren() -> [TreeTestItem] {
        children
    }
}
