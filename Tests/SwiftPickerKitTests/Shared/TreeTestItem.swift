@testable import SwiftPickerKit

struct TreeTestItem: TreeNodePickerItem {
    let name: String
    let children: [TreeTestItem]
    let metadata: TreeNodeMetadata?
    let hasChildrenValue: Bool
    let isSelectable: Bool

    var hasChildren: Bool { hasChildrenValue }

    var displayName: String { name }

    func loadChildren() -> [TreeTestItem] {
        children
    }
}
