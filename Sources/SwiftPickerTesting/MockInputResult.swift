//
//  MockInputResult.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Configures how `MockSwiftPicker` responds to text prompts.
public struct MockInputResult {
    public var type: MockInputType
    public var defaultValue: String

    public init(defaultValue: String = "", type: MockInputType = .ordered([])) {
        self.defaultValue = defaultValue
        self.type = type
    }
}


// MARK: - Response Type
public enum MockInputType {
    case ordered([String])
    case dictionary([String: String])
}


// MARK: - Internal Helpers
extension MockInputResult {
    mutating func nextResponse(for prompt: String) -> String {
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
