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
        rootDisplayName: String?,
        newScreen: Bool,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) -> Item? {
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let state = TreeNavigationState(
            rootItems: rootItems,
            rootDisplayName: rootDisplayName,
            prompt: prompt,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
        let behavior = TreeNavigationBehavior<Item>()
        let renderer = TreeNavigationRenderer<Item>()

        state.startAtRootContentsIfNeeded()

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
