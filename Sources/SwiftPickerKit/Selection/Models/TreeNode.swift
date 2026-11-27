public struct TreeNode<T>: TreeNodePickerItem, StyledPickerItem {
    public let displayName: String
    public let value: T
    public let metadata: TreeNodeMetadata?

    /// How this node's row is drawn, or `nil` for the theme's default.
    public let displayStyle: PickerTextStyle?
    public let isSelectable: Bool
    private let childrenLoader: () -> [TreeNode<T>]

    // Lazy caching
    private var cachedChildren: [TreeNode<T>]?
    public var hasChildren: Bool { cachedChildren?.isEmpty == false || _hasChildren }

    private let _hasChildren: Bool

    public init(
        name: String,
        value: T,
        hasChildren: Bool = false,
        isSelectable: Bool = true,
        metadata: TreeNodeMetadata? = nil,
        loadChildren: @escaping () -> [TreeNode<T>]
    ) {
        self.init(name: name, value: value, hasChildren: hasChildren, isSelectable: isSelectable, metadata: metadata, displayStyle: nil, loadChildren: loadChildren)
    }

    /// Creates a node whose row is drawn in `displayStyle`.
    ///
    /// - Parameters:
    ///   - name: The text shown for the node.
    ///   - value: The value carried by the node.
    ///   - hasChildren: Whether the node can be entered before its children are loaded.
    ///   - isSelectable: Whether Enter can select the node.
    ///   - metadata: Subtitle, detail lines, and icon shown for the node.
    ///   - displayStyle: The row's style, or `nil` for the theme's default.
    ///   - loadChildren: Loads the node's children when it is entered.
    public init(
        name: String,
        value: T,
        hasChildren: Bool,
        isSelectable: Bool,
        metadata: TreeNodeMetadata?,
        displayStyle: PickerTextStyle?,
        loadChildren: @escaping () -> [TreeNode<T>]
    ) {
        self.displayName = name
        self.value = value
        self.metadata = metadata
        self.displayStyle = displayStyle
        self.isSelectable = isSelectable
        self.childrenLoader = loadChildren
        self._hasChildren = hasChildren
    }

    public func loadChildren() -> [TreeNode<T>] {
        if let cached = cachedChildren {
            return cached
        }
        let children = childrenLoader()
        return children
    }
}
