public enum PickerLayout<Item: DisplayablePickerItem> {
    case singleColumn
    case twoColumnStatic(detailText: String)
    case twoColumnDynamic(detailForItem: (Item) -> String)
}
