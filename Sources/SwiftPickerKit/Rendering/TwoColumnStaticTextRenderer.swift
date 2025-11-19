//
//  TwoColumnStaticTextRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

struct TwoColumnStaticTextRenderer<Item: DisplayablePickerItem>: ContentRenderer {

    typealias State = TwoColumnStaticTextState<Item>

    func render(
        items: [Item],
        state: TwoColumnStaticTextState<Item>,
        context: ScrollRenderContext,
        input: PickerInput,
        screenWidth: Int
    ) {
        let leftWidth = max(18, screenWidth / 3)        // More room for list labels
        let rightWidth = screenWidth - leftWidth - 3     // 3 = border + spacing

        var row = context.listStartRow

        // ---------------------------------------------------------
        // LEFT COLUMN — list selection
        // ---------------------------------------------------------
        for index in context.startIndex..<context.endIndex {
            let option = state.left.options[index]
            let isActive = (index == state.left.activeIndex)

            input.moveTo(row, 0)
            input.moveRight()

            // Marker
            let marker: String
            if state.left.isSingleSelection {
                marker = isActive ? "●".lightGreen : "○".foreColor(250)
            } else {
                marker = option.isSelected ? "●".lightGreen : "○".foreColor(250)
            }
            input.write(marker)
            input.moveRight()

            // Title
            let maxLeftText = leftWidth - 4
            let truncated = PickerTextFormatter.truncate(option.title, maxWidth: maxLeftText)

            if isActive { input.write(truncated.underline) }
            else { input.write(truncated.foreColor(250)) }

            row += 1
        }

        // ---------------------------------------------------------
        // RIGHT COLUMN — static text block rendered independently
        // ---------------------------------------------------------
        renderRightColumnBlock(
            fullTextLines: state.wrappedRightLines(width: rightWidth),
            context: context,
            leftWidth: leftWidth,
            rightWidth: rightWidth,
            input: input
        )
    }
}

// MARK: - Right Column Block Rendering

private extension TwoColumnStaticTextRenderer {

    func renderRightColumnBlock(
        fullTextLines: [String],
        context: ScrollRenderContext,
        leftWidth: Int,
        rightWidth: Int,
        input: PickerInput
    ) {
        var row = context.listStartRow

        for line in fullTextLines {
            if row >= context.listStartRow + context.visibleRowCount {
                break // no more vertical space
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
