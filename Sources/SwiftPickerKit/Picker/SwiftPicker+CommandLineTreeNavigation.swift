//
//  SwiftPicker+CommandLineTreeNavigation.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

extension SwiftPicker: CommandLineTreeNavigation {
    public func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool
    ) -> Item? {
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let state = TreeNavigationState(rootItems: rootItems, prompt: prompt)
        let behavior = TreeNavigationBehavior<Item>(allowSelectingFolders: allowSelectingFolders)
        let renderer = TreeNavigationRenderer<Item>()

        if startInsideFirstRoot {
            state.activeIndex = 0
            state.descendIntoChildIfPossible()
        }

        let handler = SelectionHandler(
            state: state,
            pickerInput: pickerInput,
            behavior: behavior,
            renderer: renderer
        )

        let outcome = handler.captureUserInput()
        handler.endSelection()

        switch outcome {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    public func requiredTreeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool,
        startInsideFirstRoot: Bool,
        newScreen: Bool
    ) throws -> Item {
        guard let selection = treeNavigation(
            prompt: prompt,
            rootItems: rootItems,
            allowSelectingFolders: allowSelectingFolders,
            startInsideFirstRoot: startInsideFirstRoot,
            newScreen: newScreen
        ) else {
            throw SwiftPickerError.selectionCancelled
        }
        return selection
    }
}
