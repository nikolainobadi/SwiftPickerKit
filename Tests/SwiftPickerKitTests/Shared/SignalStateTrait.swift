//
//  SignalStateTrait.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Testing

/// Runs each test case in a suite one at a time with every other suite carrying this trait.
///
/// Signal dispositions and `SignalHandler`'s storage are process-global, and any test that
/// runs a picker's input loop installs and removes the handlers. `.serialized` only orders
/// tests within one suite, so suites that touch this state share a lock instead.
struct SignalStateTrait: SuiteTrait, TestTrait, TestScoping {
    var isRecursive: Bool {
        return true
    }

    func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        await SignalStateLock.shared.acquire()

        do {
            try await function()
        } catch {
            await SignalStateLock.shared.release()
            throw error
        }

        await SignalStateLock.shared.release()
    }
}

extension Trait where Self == SignalStateTrait {
    /// Serializes the suite against every other suite that touches process signal state.
    static var signalState: Self {
        return SignalStateTrait()
    }
}

// MARK: - Lock
private actor SignalStateLock {
    static let shared = SignalStateLock()

    private var isLocked = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func acquire() async {
        guard isLocked else {
            isLocked = true
            return
        }

        await withCheckedContinuation { waiters.append($0) }
    }

    func release() {
        if waiters.isEmpty {
            isLocked = false
        } else {
            waiters.removeFirst().resume()
        }
    }
}
