//
//  DisplayablePickerItem.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public protocol DisplayablePickerItem {
    var displayName: String { get }
}

extension String: DisplayablePickerItem {
    public var displayName: String { self }
}
