import SwiftPickerKit

struct TestItem: DisplayablePickerItem {
    let name: String
    
    var displayName: String {
        return name
    }
    
    var description: String {
        return "Description for \(name)"
    }
}
