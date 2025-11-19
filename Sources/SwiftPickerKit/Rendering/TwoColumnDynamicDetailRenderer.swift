//
//  TwoColumnDynamicDetailRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TwoColumnDynamicDetailRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    func render(
        items: [Item],
        state: TwoColumnDynamicDetailState<Item>,
        context: ScrollRenderContext,
        input: any PickerInput,
        screenWidth: Int
    ) {
        let leftWidth = max(18, screenWidth / 3)
        let rightWidth = screenWidth - leftWidth - 3

        var row = context.listStartRow

        // LEFT COLUMN (same as static)
        for index in context.startIndex..<context.endIndex {
            let option = state.left.options[index]
            let isActive = index == state.activeIndex

            input.moveTo(row, 0)
            input.moveRight()

            let marker = optionMarker(option: option, isActive: isActive, isSingle: state.left.isSingleSelection)
            input.write(marker)
            input.moveRight()

            let text = PickerTextFormatter.truncate(option.title, maxWidth: leftWidth - 4)
            input.write(isActive ? text.underline : text.foreColor(250))

            row += 1
        }

        // RIGHT COLUMN — dynamic text
        let item = state.left.options[state.activeIndex].item
        let lines = state.detailForItem(item).wrapToWidth(maxWidth: rightWidth)

        row = context.listStartRow
        for line in lines {
            if row >= context.listStartRow + context.visibleRowCount { break }
            input.moveTo(row, leftWidth)
            input.write("│ ".foreColor(240))
            let truncated = PickerTextFormatter.truncate(line, maxWidth: rightWidth)
            input.write(truncated.foreColor(250))
            row += 1
        }
    }

    private func optionMarker(option: Option<Item>, isActive: Bool, isSingle: Bool) -> String {
        if isSingle { return isActive ? "●".lightGreen : "○".foreColor(250) }
        return option.isSelected ? "●".lightGreen : "○".foreColor(250)
    }
}
