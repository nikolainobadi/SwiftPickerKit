//
//  SwiftPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public struct SwiftPicker {
    let textInput: TextInput
    let pickerInput: PickerInput
    
    init(textInput: TextInput, pickerInput: PickerInput) {
        self.textInput = textInput
        self.pickerInput = pickerInput
    }
}


// MARK: - Init
public extension SwiftPicker {
    init() {
        self.init(textInput: DefaultTextInput(), pickerInput: DefaultPickerInput())
    }
}


// MARK: - Core Selection Runner
internal extension SwiftPicker {
    @discardableResult
    func runSelection<Item, B: SelectionBehavior>(
        prompt: String,
        items: [Item],
        behavior: B,
        isSingle: Bool,
        newScreen: Bool
    ) -> SelectionOutcome<Item>
    where
        B.Item == Item,
        B.State == SelectionState<Item>,
        Item: DisplayablePickerItem
    {
        if newScreen {
            pickerInput.enterAlternativeScreen()
        }
        
        pickerInput.cursorOff()
        pickerInput.clearScreen()
        pickerInput.moveToHome()
        
        // No more topLine, no more line-based options
        let options = items.map { Option(item: $0) }

        let state = SelectionState(
            options: options,
            prompt: prompt,
            isSingleSelection: isSingle
        )
        
        let handler = SelectionHandler(
            state: state,
            pickerInput: pickerInput,
            behavior: behavior,
            renderer: SingleColumnRenderer<Item>()
        )
        
        let outcome = handler.captureUserInput()
        handler.endSelection()
        return outcome
    }
}


// MARK: - Dependencies (unchanged)
enum Direction { case up, down, left, right }
enum SpecialChar { case enter, space, quit, backspace }

protocol TextInput {
    func getInput(_ prompt: String) -> String
    func getPermission(_ prompt: String) -> Bool
}

protocol PickerInput {
    func cursorOff()
    func moveRight()
    func moveToHome()
    func clearBuffer()
    func clearScreen()
    func enableNormalInput()
    func keyPressed() -> Bool
    func write(_ text: String)
    func exitAlternativeScreen()
    func enterAlternativeScreen()
    func moveTo(_ row: Int, _ col: Int)
    func readDirectionKey() -> Direction?
    func readSpecialChar() -> SpecialChar?
    func readCursorPos() -> (row: Int, col: Int)
    func readScreenSize() -> (rows: Int, cols: Int)
}

extension SwiftPicker {
    public func singleSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) -> Item? {
        switch runSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            isSingle: true,
            newScreen: newScreen
        ) {
        case .finishSingle(let item):
            return item
        default:
            return nil
        }
    }

    public func requiredSingleSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) throws -> Item {
        guard let value = singleSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            newScreen: newScreen
        ) else {
            throw SwiftPickerError.selectionCancelled
        }
        return value
    }
    
    public func multiSelection<Item: DisplayablePickerItem>(
        prompt: String,
        items: [Item],
        layout: PickerLayout<Item> = .singleColumn,
        newScreen: Bool = true
    ) -> [Item] {
        switch runSelection(
            prompt: prompt,
            items: items,
            layout: layout,
            isSingle: false,
            newScreen: newScreen
        ) {
        case .finishMulti(let items):
            return items
        default:
            return []
        }
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
