//
//  PickerPrompt.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

public protocol PickerPrompt {
    var title: String { get }
}

extension String: PickerPrompt {
    public var title: String {
        return self
    }
}
