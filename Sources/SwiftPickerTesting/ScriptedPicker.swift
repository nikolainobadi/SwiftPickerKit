//
//  ScriptedPicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 9/6/26.
//

/// Builds a `MockSwiftPicker` from ordered queues, one per kind of question.
///
/// A test names only the queues it exercises; the rest stay empty and answer their fallback. That
/// omission is the point — a call that names `inputs` alone says the flow under test asks for text
/// and nothing else, which naming five queues would bury.
///
/// The queues fall back rather than trap when they run dry: input answers `""`, permission answers
/// `false`, and the selections answer "nothing chosen". Those fallbacks belong to the `Mock*Result`
/// types, not to this one — a flow that asks permission inside a `while` loop terminates because
/// `MockPermissionResult` defaults to `false`, whether or not the picker was built here.
public enum ScriptedPicker {
    /// Creates a picker that answers each kind of prompt from its own ordered queue.
    ///
    /// Queues are consumed independently and in call order: the third `getInput` takes the third
    /// element of `inputs` regardless of how many permission prompts came between. A queue that
    /// runs out answers its fallback from then on, so a scripted flow that asks more questions than
    /// expected degrades to "no" and "nothing chosen" instead of repeating its last answer.
    ///
    /// - Parameters:
    ///   - permissions: Answers for `getPermission`, in call order. Falls back to `false`.
    ///   - singles: Outcomes for `singleSelection`, in call order. Falls back to `.none`.
    ///   - multis: Outcomes for `multiSelection`, in call order. Falls back to `.none`.
    ///   - inputs: Answers for `getInput`, in call order. Falls back to `""`.
    ///   - treeNavigations: Outcomes for `treeNavigation`, in call order. Falls back to `.none`.
    /// - Returns: A picker scripted with the given queues.
    public static func make(
        permissions: [Bool] = [],
        singles: [MockSingleSelectionOutcome] = [],
        multis: [MockMultiSelectionOutcome] = [],
        inputs: [String] = [],
        treeNavigations: [MockTreeSelectionOutcome] = []
    ) -> MockSwiftPicker {
        return .init(
            inputResult: .init(defaultValue: "", type: .ordered(inputs)),
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

    /// Creates a picker with every queue empty, so each prompt answers its fallback.
    ///
    /// For tests that need a picker in the dependency graph but expect nothing to be asked, or that
    /// assert only on the `captured*Prompts` arrays. Prompts are still recorded.
    ///
    /// - Returns: A picker that answers `""`, `false`, and "nothing chosen".
    public static func silent() -> MockSwiftPicker {
        return make()
    }
}
