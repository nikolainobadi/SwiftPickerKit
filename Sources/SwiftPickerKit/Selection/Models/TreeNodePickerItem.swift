import Foundation

public protocol TreeNodePickerItem: DisplayablePickerItem {
    var hasChildren: Bool { get }
    func loadChildren() -> [Self]
    var metadata: TreeNodeMetadata? { get }
    var isSelectable: Bool { get }
}
