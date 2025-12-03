//
//  SwiftPicker+CommandLineSelection.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

extension SwiftPicker: CommandLineSelection {
    public func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> Item? {
        switch runSelection(prompt: prompt, items: items, layout: layout, isSingle: true, newScreen: newScreen, showSelectedItemText: showSelectedItemText) {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    public func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> [Item] {
        switch runSelection(prompt: prompt, items: items, layout: layout, isSingle: false, newScreen: newScreen, showSelectedItemText: showSelectedItemText) {
        case .finishMulti(let items):
            return items
        default:
            return []
        }
    }
}


// MARK: - Private Methods
private extension SwiftPicker {
    @discardableResult
    func runSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item>,
        isSingle: Bool,
        newScreen: Bool,
        showSelectedItemText: Bool = true
    ) -> SelectionOutcome<Item> {
        prepareScreen(newScreen: newScreen)
        let baseState = makeBaseState(
            items: items,
            prompt: prompt,
            isSingle: isSingle,
            showSelectedItemText: showSelectedItemText
        )

        switch layout {
        case .singleColumn:
            return runSingleColumnSelection(state: baseState, isSingle: isSingle)
        case .twoColumnStatic(let detailText):
            return runTwoColumnStaticSelection(
                leftState: baseState,
                detailText: detailText,
                isSingle: isSingle
            )
        case .twoColumnDynamic(let detailForItem):
            return runTwoColumnDynamicSelection(
                leftState: baseState,
                detailForItem: detailForItem,
                isSingle: isSingle
            )
        }
    }

    func prepareScreen(newScreen: Bool) {
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }

        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()
    }

    func makeBaseState<Item: DisplayablePickerItem>(
        items: [Item],
        prompt: String,
        isSingle: Bool,
        showSelectedItemText: Bool
    ) -> SelectionState<Item> {
        let options = items.map { Option(item: $0) }

        return SelectionState(
            options: options,
            prompt: prompt,
            isSingleSelection: isSingle,
            showSelectedItemText: showSelectedItemText
        )
    }

    func runSingleColumnSelection<Item: DisplayablePickerItem>(
        state: SelectionState<Item>,
        isSingle: Bool
    ) -> SelectionOutcome<Item> {
        let renderer = SingleColumnRenderer<Item>()

        if isSingle {
            let behavior = SingleSelectionBehavior<Item>()
            return captureSelection(state: state, behavior: behavior, renderer: renderer)
        }

        let behavior = MultiSelectionBehavior<Item>()
        return captureSelection(state: state, behavior: behavior, renderer: renderer)
    }

    func runTwoColumnStaticSelection<Item: DisplayablePickerItem>(
        leftState: SelectionState<Item>,
        detailText: String,
        isSingle: Bool
    ) -> SelectionOutcome<Item> {
        let state = TwoColumnStaticTextState(
            leftState: leftState,
            rightText: detailText
        )
        let renderer = TwoColumnStaticTextRenderer<Item>()

        if isSingle {
            let behavior = TwoColumnStaticTextSingleBehavior<Item>()
            return captureSelection(state: state, behavior: behavior, renderer: renderer)
        }

        let behavior = TwoColumnStaticTextMultiBehavior<Item>()
        return captureSelection(state: state, behavior: behavior, renderer: renderer)
    }

    func runTwoColumnDynamicSelection<Item: DisplayablePickerItem>(
        leftState: SelectionState<Item>,
        detailForItem: @escaping (Item) -> String,
        isSingle: Bool
    ) -> SelectionOutcome<Item> {
        let state = TwoColumnDynamicDetailState(
            leftState: leftState,
            detailForItem: detailForItem
        )
        let renderer = TwoColumnDynamicDetailRenderer<Item>()

        if isSingle {
            let behavior = TwoColumnDynamicDetailSingleBehavior<Item>()
            return captureSelection(state: state, behavior: behavior, renderer: renderer)
        }

        let behavior = TwoColumnDynamicDetailMultiBehavior<Item>()
        return captureSelection(state: state, behavior: behavior, renderer: renderer)
    }

    func captureSelection<Behavior, Renderer>(
        state: Behavior.State,
        behavior: Behavior,
        renderer: Renderer
    ) -> SelectionOutcome<Behavior.Item> where
        Behavior: SelectionBehavior,
        Renderer: ContentRenderer,
        Behavior.State == Renderer.State,
        Behavior.Item == Renderer.Item {
        let handler = SelectionHandler(
            state: state,
            pickerInput: pickerInput,
            behavior: behavior,
            renderer: renderer
        )
        return handler.captureUserInput()
    }
}
