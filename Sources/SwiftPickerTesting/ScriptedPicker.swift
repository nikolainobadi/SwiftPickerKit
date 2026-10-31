//
//  ScriptedPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 9/6/26.
//

/// Builds a `MockSwiftPicker` from ordered queues, one per kind of question.
///
/// A test names only the queues its flow uses; omitting the rest signals that the flow asks
/// nothing else. A drained queue falls back rather than traps: text and secret input answer `""`,
/// permission `false`, and selections "nothing chosen". Those fallbacks come from the `Mock*Result`
/// defaults, so a permission prompt in a `while` loop terminates with any `MockSwiftPicker`.
public enum ScriptedPicker {
    /// Creates a picker that answers each kind of prompt from its own ordered queue.
    ///
    /// Queues advance independently: the third `getInput` takes the third element of `inputs`
    /// however many other prompts came between. Once drained, a queue answers its fallback rather
    /// than repeating its last answer.
    ///
    /// - Parameters:
    ///   - permissions: Answers for `getPermission`, in call order. Falls back to `false`.
    ///   - singles: Outcomes for `singleSelection`, in call order. Falls back to `.none`.
    ///   - multis: Outcomes for `multiSelection`, in call order. Falls back to `.none`.
    ///   - inputs: Answers for `getInput`, in call order. Falls back to `""`.
    ///   - secretInputs: Answers for `getSecretInput`, in call order. Falls back to `""`.
    ///   - treeNavigations: Outcomes for `treeNavigation`, in call order. Falls back to `.none`.
    /// - Returns: A picker scripted with the given queues.
    public static func make(
        permissions: [Bool] = [],
        singles: [MockSingleSelectionOutcome] = [],
        multis: [MockMultiSelectionOutcome] = [],
        inputs: [String] = [],
        secretInputs: [String] = [],
        treeNavigations: [MockTreeSelectionOutcome] = []
    ) -> MockSwiftPicker {
        return .init(
            inputResult: .init(defaultValue: "", type: .ordered(inputs)),
            secretInputResult: .init(defaultValue: "", type: .ordered(secretInputs)),
            permissionResult: .init(defaultValue: false, type: .ordered(permissions)),
            selectionResult: .init(
                defaultSingle: .none,
                defaultMulti: .none,
                singleType: .ordered(singles),
                multiType: .ordered(multis)
            ),
            treeNavigationResult: .init(defaultOutcome: .none, type: .ordered(treeNavigations))
        )
    }

    /// Creates a picker with every queue empty, for tests that expect no prompts or assert only on
    /// the `captured*Prompts` arrays.
    ///
    /// - Returns: A picker that answers `""`, `false`, and "nothing chosen".
    public static func silent() -> MockSwiftPicker {
        return make()
    }
}
