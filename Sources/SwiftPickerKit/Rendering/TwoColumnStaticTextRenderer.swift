//
//  TwoColumnStaticTextRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TwoColumnStaticTextRenderer<Item: DisplayablePickerItem>: ContentRenderer {
    func render(items: [Item], state: TwoColumnStaticTextState<Item>, context: ScrollRenderContext, input: any PickerInput, screenWidth: Int) {
        let leftWidth = max(18, screenWidth / 3)
        let rightWidth = screenWidth - leftWidth - 3

        var row = context.listStartRow

        for index in context.startIndex..<context.endIndex {
            let option = state.leftState.options[index]
            let isActive = index == state.leftState.activeIndex

            input.moveTo(row, 0)
            input.moveRight()

            let marker: String
            if state.leftState.isSingleSelection {
                marker = isActive ? "●".lightGreen : "○".foreColor(250)
            } else {
                marker = option.isSelected ? "●".lightGreen : "○".foreColor(250)
            }
            input.write(marker)
            input.moveRight()

            let maxLeftText = leftWidth - 4
            let truncated = PickerTextFormatter.truncate(option.title, maxWidth: maxLeftText)
            input.write(isActive ? truncated.underline : truncated.foreColor(250))

            row += 1
        }

        renderRightColumnBlock(
            fullTextLines: state.wrappedRightLines(width: rightWidth),
            context: context,
            leftWidth: leftWidth,
            rightWidth: rightWidth,
            input: input
        )
    }
}


// MARK: - Private Methods
private extension TwoColumnStaticTextRenderer {
    func renderRightColumnBlock(fullTextLines: [String], context: ScrollRenderContext, leftWidth: Int, rightWidth: Int, input: PickerInput) {
        var row = context.listStartRow

        for line in fullTextLines {
            if row >= context.listStartRow + context.visibleRowCount {
                break
            }

            input.moveTo(row, leftWidth)
            input.write("│".foreColor(240))
            input.moveRight()

            let truncated = PickerTextFormatter.truncate(line, maxWidth: rightWidth - 2)
            input.write(truncated.foreColor(250))

            row += 1
        }
    }
}
