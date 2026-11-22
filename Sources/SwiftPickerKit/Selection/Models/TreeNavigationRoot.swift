/// Lightweight container that names the conceptual root of a tree and exposes its children.
public struct TreeNavigationRoot<Item: TreeNodePickerItem> {
    public let displayName: String
    public let children: [Item]

    public init(displayName: String, children: [Item]) {
        self.displayName = displayName
        self.children = children
    }
}
