//
//  SwiftPicker+CommandLineSelection.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

extension SwiftPicker: CommandLineSelection {
    public func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool) -> Item? {
        switch runSelection(prompt: prompt, items: items, layout: layout, isSingle: true, newScreen: newScreen) {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    public func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool) throws -> Item {
        guard let value = singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen) else {
            throw SwiftPickerError.selectionCancelled
        }
        
        return value
    }

    public func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool) -> [Item] {
        switch runSelection(prompt: prompt, items: items, layout: layout, isSingle: false, newScreen: newScreen) {
        case .finishMulti(let items):
            return items
        default:
            return []
        }
    }
}

public extension SwiftPicker {
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item]) -> Item? {
        let selection = singleSelection(prompt: prompt, items: items, layout: .singleColumn, newScreen: true)
        if let item = selection {
            print("\nInteractivePicker SingleSelection result:\n  \("✔".green) \(item)\n")
        }
        return selection
    }

    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item]) throws -> Item {
        guard let item = singleSelection(prompt: prompt, items: items) else {
            throw SwiftPickerError.selectionCancelled
        }
        return item
    }

    func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item]) -> [Item] {
        let selections = multiSelection(prompt: prompt, items: items, layout: .singleColumn, newScreen: true)
        if !selections.isEmpty {
            print("\nInteractivePicker MultiSelection results:\n")
            selections.forEach { print(" \("✔".green) \($0)") }
            print("")
        }
        return selections
    }
}


internal extension SwiftPicker {
    @discardableResult
    func runSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item>,
        isSingle: Bool,
        newScreen: Bool
    ) -> SelectionOutcome<Item> {

        if newScreen {
            pickerInput.enterAlternativeScreen()
        }

        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()

        let options = items.map { Option(item: $0) }

        // Base state for single-column or left-column of two-column
        let baseState = SelectionState(
            options: options,
            prompt: prompt,
            isSingleSelection: isSingle
        )

        switch layout {

        // -----------------------------------------------------
        // 1. SINGLE COLUMN
        // -----------------------------------------------------
        case .singleColumn:

            if isSingle {
                let behavior = SingleSelectionBehavior<Item>()
                let renderer = SingleColumnRenderer<Item>()

                let handler = SelectionHandler(
                    state: baseState,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()

            } else {
                let behavior = MultiSelectionBehavior<Item>()
                let renderer = SingleColumnRenderer<Item>()

                let handler = SelectionHandler(
                    state: baseState,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            }

        // -----------------------------------------------------
        // 2. TWO COLUMN STATIC
        // -----------------------------------------------------
        case .twoColumnStatic(let detailText):

            let state = TwoColumnStaticTextState(
                left: baseState,
                rightText: detailText
            )
            let renderer = TwoColumnStaticTextRenderer<Item>()

            if isSingle {
                let behavior = TwoColumnStaticTextSingleBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()

            } else {
                let behavior = TwoColumnStaticTextMultiBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            }

        // -----------------------------------------------------
        // 3. TWO COLUMN DYNAMIC
        // -----------------------------------------------------
        case .twoColumnDynamic(let detailForItem):

            let state = TwoColumnDynamicDetailState(
                left: baseState,
                detailForItem: detailForItem
            )
            let renderer = TwoColumnDynamicDetailRenderer<Item>()

            if isSingle {
                let behavior = TwoColumnDynamicDetailSingleBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            } else {
                let behavior = TwoColumnDynamicDetailMultiBehavior<Item>()
                let handler = SelectionHandler(
                    state: state,
                    pickerInput: pickerInput,
                    behavior: behavior,
                    renderer: renderer
                )
                return handler.captureUserInput()
            }
        }
    }
}
