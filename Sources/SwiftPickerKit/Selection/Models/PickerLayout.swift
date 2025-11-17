//
//  PickerLayout.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

public enum PickerLayout<Item: DisplayablePickerItem> {
    case singleColumn
    case twoColumnStatic(detailText: String)
    case twoColumnDynamic(detailForItem: (Item) -> String)
}
