//
//  TestItem.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/19/25.
//

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
