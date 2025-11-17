//
//  TreeNode.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

public struct TreeNode<T>: TreeNodePickerItem {
    public let displayName: String
    public let value: T
    public let metadata: TreeNodeMetadata?
    private let childrenLoader: () -> [TreeNode<T>]

    // Lazy caching
    private var cachedChildren: [TreeNode<T>]?
    public var hasChildren: Bool { cachedChildren?.isEmpty == false || _hasChildren }

    private let _hasChildren: Bool

    public init(
        name: String,
        value: T,
        hasChildren: Bool = false,
        metadata: TreeNodeMetadata? = nil,
        loadChildren: @escaping () -> [TreeNode<T>]
    ) {
        self.displayName = name
        self.value = value
        self.metadata = metadata
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
