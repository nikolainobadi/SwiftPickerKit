//
//  SingleColumnRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct SingleColumnRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    func render(
        items: [Item],
        state: SelectionState<Item>,
        context: ScrollRenderContext,
        using input: PickerInput,
        screenWidth: Int
    ) {
        var row = context.listStartRow

        for index in context.startIndex..<context.endIndex {
            let option = state.options[index]
            let isActive = (index == state.activeIndex)

            input.moveTo(row, 0)
            input.moveRight()

            let marker: String
            if state.isSingleSelection {
                marker = isActive ? "●".lightGreen : "○".foreColor(250)
            } else {
                marker = option.isSelected ? "●".lightGreen : "○".foreColor(250)
            }

            input.write(marker)
            input.moveRight()

            let maxWidth = screenWidth - 4
            let text = PickerTextFormatter.truncate(option.title, maxWidth: maxWidth)

            if isActive {
                input.write(text.underline)
            } else {
                input.write(text.foreColor(250))
            }

            row += 1
        }
    }
}
