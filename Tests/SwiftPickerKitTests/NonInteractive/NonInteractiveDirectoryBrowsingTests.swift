//
//  NonInteractiveDirectoryBrowsingTests.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 08/09/26.
//

import Testing
import Foundation
@testable import SwiftPickerKit

/// `browseDirectories` reaches two different implementations depending on how it is called, and
/// only one of them is free of side effects. These tests pin both.
///
/// Serialized because they read and write `FileSystemNode.selectionType`, which is process-global.
@Suite(.serialized)
struct NonInteractiveDirectoryBrowsingTests {
    @Test("Returns nil when called on the concrete type")
    func returnsNilWhenCalledOnTheConcreteType() {
        let sut = makeSUT()

        #expect(sut.browseDirectories(prompt: "Browse", startURL: makeTemporaryURL()) == nil)
    }

    @Test("Returns nil when called through the picker existential")
    func returnsNilWhenCalledThroughThePickerExistential() {
        // Omitting the trailing arguments binds to the convenience overload in
        // CommandLineTreeNavigation rather than the struct's member. The result contract holds
        // on that path too, which is what this asserts.
        let sut: any CommandLinePicker = makeSUT()

        #expect(sut.browseDirectories(prompt: "Browse", startURL: makeTemporaryURL()) == nil)
    }

    @Test("Concrete calls leave the selection type global untouched")
    func concreteCallsLeaveTheSelectionTypeGlobalUntouched() {
        let original = FileSystemNode.selectionType
        defer { FileSystemNode.selectionType = original }

        FileSystemNode.selectionType = .filesAndFolders
        let sut = makeSUT()

        _ = sut.browseDirectories(prompt: "Browse", startURL: makeTemporaryURL(), showPromptText: true, showSelectedItemText: true, selectionType: .onlyFiles)

        #expect(FileSystemNode.selectionType == .filesAndFolders)
    }

    @Test("Existential calls with omitted arguments mutate the selection type global")
    func existentialCallsWithOmittedArgumentsMutateTheSelectionTypeGlobal() {
        // Characterization, not a desired guarantee. Default arguments on a protocol extension
        // member bind statically, so this path runs CommandLineTreeNavigation's convenience
        // overload — which reads a directory listing and assigns the global before delegating.
        // Documented on NonInteractivePicker. If a future change routes this to the struct's
        // member instead, this test flips and the doc comment should be updated with it.
        let original = FileSystemNode.selectionType
        defer { FileSystemNode.selectionType = original }

        FileSystemNode.selectionType = .filesAndFolders
        let sut: any CommandLinePicker = makeSUT()

        _ = sut.browseDirectories(prompt: "Browse", startURL: makeTemporaryURL(), selectionType: .onlyFiles)

        #expect(FileSystemNode.selectionType == .onlyFiles)
    }
}


// MARK: - SUT
private extension NonInteractiveDirectoryBrowsingTests {
    func makeSUT(assumeYes: Bool = false) -> NonInteractivePicker {
        return NonInteractivePicker(assumeYes: assumeYes)
    }

    func makeTemporaryURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
}
