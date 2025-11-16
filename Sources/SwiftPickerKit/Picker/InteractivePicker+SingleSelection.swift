//
//  InteractivePicker+SingleSelection.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public extension InteractivePicker {
    func requiredSingleSelection<Item: DisplayablePickerItem>(
        title: PickerPrompt,
        items: [Item]
    ) throws -> Item {
        guard let item = singleSelection(title: title, items: items) else {
            throw SwiftPickerError.selectionCancelled
        }
        return item
    }

    func singleSelection<Item: DisplayablePickerItem>(
        title prompt: PickerPrompt,
        items: [Item]
    ) -> Item? {

        let outcome = runSelection(
            title: prompt,
            items: items,
            behavior: SingleSelectionBehavior<Item>(),
            isSingle: true,
            newScreen: true
        )

        if case .finishSingle(let item) = outcome {
            if let item {
                print("\nInteractivePicker SingleSelection result:\n  \("✔".green) \(item)\n")
            }
            return item
        }

        return nil
    }
}
