//
//  MockSelectionResult.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Configures how `MockSwiftPicker` responds to selection prompts.
public struct MockSelectionResult {
    public var defaultSingle: MockSingleSelectionOutcome
    public var defaultMulti: MockMultiSelectionOutcome
    public var singleType: MockSingleSelectionType
    public var multiType: MockMultiSelectionType

    public init(
        defaultSingle: MockSingleSelectionOutcome = .none,
        defaultMulti: MockMultiSelectionOutcome = .none,
        singleType: MockSingleSelectionType = .ordered([]),
        multiType: MockMultiSelectionType = .ordered([])
    ) {
        self.defaultSingle = defaultSingle
        self.defaultMulti = defaultMulti
        self.singleType = singleType
        self.multiType = multiType
    }
}


// MARK: - Response Types
public enum MockSingleSelectionType {
    case ordered([MockSingleSelectionOutcome])
    case dictionary([String: MockSingleSelectionOutcome])
}

public enum MockMultiSelectionType {
    case ordered([MockMultiSelectionOutcome])
    case dictionary([String: MockMultiSelectionOutcome])
}


// MARK: - Responses
public struct MockSingleSelectionOutcome: Equatable {
    public var selectedIndex: Int?

    public init(selectedIndex: Int?) {
        self.selectedIndex = selectedIndex
    }

    public static let none: MockSingleSelectionOutcome = .init(selectedIndex: nil)

    public static func index(_ index: Int) -> MockSingleSelectionOutcome {
        return .init(selectedIndex: index)
    }
}

public struct MockMultiSelectionOutcome: Equatable {
    public var selectedIndices: [Int]

    public init(selectedIndices: [Int]) {
        self.selectedIndices = selectedIndices
    }

    public static let none: MockMultiSelectionOutcome = .init(selectedIndices: [])

    public static func indices(_ indices: [Int]) -> MockMultiSelectionOutcome {
        return .init(selectedIndices: indices)
    }
}


// MARK: - Internal Helpers
extension MockSelectionResult {
    mutating func nextSingleOutcome(for prompt: String) -> MockSingleSelectionOutcome {
        switch singleType {
        case .ordered(var responses):
            guard !responses.isEmpty else {
                return defaultSingle
            }

            let result = responses.removeFirst()
            singleType = .ordered(responses)
            return result
        case .dictionary(let mapping):
            return mapping[prompt] ?? defaultSingle
        }
    }

    mutating func nextMultiOutcome(for prompt: String) -> MockMultiSelectionOutcome {
        switch multiType {
        case .ordered(var responses):
            guard !responses.isEmpty else {
                return defaultMulti
            }

            let result = responses.removeFirst()
            multiType = .ordered(responses)
            return result
        case .dictionary(let mapping):
            return mapping[prompt] ?? defaultMulti
        }
    }
}
