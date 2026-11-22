struct TwoColumnDynamicDetailSingleBehavior<Item: DisplayablePickerItem>: SelectionBehavior {

    func handleSpecialChar(char: SpecialChar, state: TwoColumnDynamicDetailState<Item>) -> SelectionOutcome<Item> {
        switch char {
        case .enter:
            let item = state.leftState.options[state.activeIndex].item
            
            return .finishSingle(item)
        case .quit:
            return .finishSingle(nil)
        case .space, .backspace:
            return .continueLoop
        }
    }
}
