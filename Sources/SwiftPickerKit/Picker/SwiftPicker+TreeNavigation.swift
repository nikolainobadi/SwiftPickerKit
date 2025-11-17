//
//  SwiftPicker+TreeNavigation.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

public extension SwiftPicker {
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        rootItems: [Item],
        allowSelectingFolders: Bool = true,
        startInsideFirstRoot: Bool = false,
        newScreen: Bool = true
    ) -> Item? {

        if newScreen { pickerInput.enterAlternativeScreen() }
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let state = TreeNavigationState(rootItems: rootItems, prompt: prompt)
        let behavior = TreeNavigationBehavior<Item>(allowSelectingFolders: allowSelectingFolders)
        let renderer = TreeNavigationRenderer<Item>()

        // Start with first root node opened
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
}
