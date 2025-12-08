//
//  MockTreeNavigationResult.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Configures how `MockSwiftPicker` responds to tree navigation prompts.
public struct MockTreeNavigationResult {
    public var defaultOutcome: MockTreeSelectionOutcome
    public var type: MockTreeSelectionType

    public init(
        defaultOutcome: MockTreeSelectionOutcome = .none,
        type: MockTreeSelectionType = .ordered([])
    ) {
        self.defaultOutcome = defaultOutcome
        self.type = type
    }
}


// MARK: - Response Types
public enum MockTreeSelectionType {
    case ordered([MockTreeSelectionOutcome])
    case dictionary([String: MockTreeSelectionOutcome])
}


// MARK: - Outcome
public struct MockTreeSelectionOutcome: Equatable {
    public var selectedRootIndex: Int?
    public var selectedChildIndex: Int?

    public init(selectedRootIndex: Int?, selectedChildIndex: Int? = nil) {
        self.selectedRootIndex = selectedRootIndex
        self.selectedChildIndex = selectedChildIndex
    }

    public static let none: MockTreeSelectionOutcome = .init(selectedRootIndex: nil, selectedChildIndex: nil)

    public static func index(_ index: Int) -> MockTreeSelectionOutcome {
        return .init(selectedRootIndex: index)
    }

    public static func child(parentIndex: Int, childIndex: Int) -> MockTreeSelectionOutcome {
        return .init(selectedRootIndex: parentIndex, selectedChildIndex: childIndex)
    }
}


// MARK: - Internal Helpers
extension MockTreeNavigationResult {
    mutating func nextOutcome(for prompt: String) -> MockTreeSelectionOutcome {
        switch type {
        case .ordered(var responses):
            guard !responses.isEmpty else {
                return defaultOutcome
            }

            let result = responses.removeFirst()
            type = .ordered(responses)
            return result
        case .dictionary(let mapping):
            return mapping[prompt] ?? defaultOutcome
        }
    }
}
