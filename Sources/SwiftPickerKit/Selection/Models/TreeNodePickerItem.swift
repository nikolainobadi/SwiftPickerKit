//
//  TreeNodePickerItem.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

import Foundation

public protocol TreeNodePickerItem: DisplayablePickerItem {
    var hasChildren: Bool { get }
    func loadChildren() -> [Self]
    var metadata: TreeNodeMetadata? { get }
    var isSelectable: Bool { get }
}

public extension TreeNodePickerItem {
    var isSelectable: Bool { true }
}
