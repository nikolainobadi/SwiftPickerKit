//
//  InteractivePicker+MultiSelection.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public extension InteractivePicker {
    func multiSelection<Item: DisplayablePickerItem>(title prompt: PickerPrompt, items: [Item]) -> [Item] {
        let outcome = runSelection(
            title: prompt,
            items: items,
            behavior: MultiSelectionBehavior<Item>(),
            isSingle: false,
            newScreen: true
        )

        if case .finishMulti(let selections) = outcome {
            if !selections.isEmpty {
                print("\nInteractivePicker MultiSelection results:\n")
                selections.forEach { print(" \("✔".green) \($0)") }
                print("")
            }
            return selections
        }

        return []
    }
}
