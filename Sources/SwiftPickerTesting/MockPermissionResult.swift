//
//  MockPermissionResult.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Configures how `MockSwiftPicker` responds to permission prompts.
public struct MockPermissionResult {
    public var type: MockPermissionType
    public var defaultValue: Bool

    public init(defaultValue: Bool = false, type: MockPermissionType = .ordered([])) {
        self.defaultValue = defaultValue
        self.type = type
    }
}


// MARK: - Response Type
public enum MockPermissionType {
    case ordered([Bool])
    case dictionary([String: Bool])
}


// MARK: - Internal Helpers
extension MockPermissionResult {
    mutating func nextResponse(for prompt: String) -> Bool {
        switch type {
        case .ordered(var responses):
            guard !responses.isEmpty else {
                return defaultValue
            }

            let result = responses.removeFirst()
            type = .ordered(responses)
            return result
        case .dictionary(let map):
            return map[prompt] ?? defaultValue
        }
    }
}
