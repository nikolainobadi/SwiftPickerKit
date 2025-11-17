//
//  TwoColumnRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Renderer for two-column layout with left column for selection and right column for display.
struct TwoColumnRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    func render(items: [Item], state: TwoColumnState<Item>, context: ScrollRenderContext, input: PickerInput, screenWidth: Int) {
        let leftColumnWidth = screenWidth / 2
        let rightColumnWidth = screenWidth - leftColumnWidth

        var row = context.listStartRow

        // Render left column (selectable items)
        for index in context.startIndex..<context.endIndex {
            let option = state.left.options[index]
            let isActive = (index == state.left.activeIndex)

            input.moveTo(row, 0)
            input.moveRight()

            // Render selection marker
            let marker: String
            if state.left.isSingleSelection {
                marker = isActive ? "●".lightGreen : "○".foreColor(250)
            } else {
                marker = option.isSelected ? "●".lightGreen : "○".foreColor(250)
            }

            input.write(marker)
            input.moveRight()

            // Render item text for left column
            let maxLeftWidth = leftColumnWidth - 4
            let leftText = PickerTextFormatter.truncate(option.title, maxWidth: maxLeftWidth)

            if isActive {
                input.write(leftText.underline)
            } else {
                input.write(leftText.foreColor(250))
            }

            // Render corresponding right column item if available
            if index < state.rightItems.count {
                let rightItem = state.rightItems[index]
                input.moveTo(row, leftColumnWidth)
                input.write("│".foreColor(240))
                input.moveRight()

                let maxRightWidth = rightColumnWidth - 3
                let rightText = PickerTextFormatter.truncate(rightItem.displayName, maxWidth: maxRightWidth)
                input.write(rightText.foreColor(250))
            }

            row += 1
        }
    }
}
