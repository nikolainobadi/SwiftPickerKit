//
//  TreeNodeMetadata.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/17/25.
//

public struct TreeNodeMetadata {
    public var subtitle: String?         // e.g. "21 files", "Updated yesterday"
    public var detailLines: [String]     // Additional info to show
    public var icon: String?             // Optional override icon

    public init(
        subtitle: String? = nil,
        detailLines: [String] = [],
        icon: String? = nil
    ) {
        self.subtitle = subtitle
        self.detailLines = detailLines
        self.icon = icon
    }
}
