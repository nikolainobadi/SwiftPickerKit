//
//  FileSystemFixture.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/21/26.
//

import Foundation
@testable import SwiftPickerKit

/// Builds throwaway directories for `FileSystemNode` tests and scopes changes to its
/// process-wide `selectionType`. Callers must run inside a `.signalState` suite so no other
/// test observes the temporary value.
enum FileSystemFixture {
    /// Creates a temporary directory holding visible files, visible folders, and hidden entries:
    /// `a-file.txt`, `b-folder/`, `c-file.txt`, `d-folder/`, `.hidden-file`, `.hidden-folder/`.
    static func makeMixedDirectory() throws -> URL {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
            .appendingPathComponent("FileSystemFixture-\(UUID().uuidString)", isDirectory: true)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        for folder in ["b-folder", "d-folder", ".hidden-folder"] {
            try fileManager.createDirectory(at: directory.appendingPathComponent(folder, isDirectory: true), withIntermediateDirectories: false)
        }

        for file in ["a-file.txt", "c-file.txt", ".hidden-file"] {
            try Data().write(to: directory.appendingPathComponent(file, isDirectory: false))
        }

        return directory
    }

    /// Runs `body` with `FileSystemNode.selectionType` set to `selectionType`, then restores the previous value.
    static func withSelectionType<T>(_ selectionType: FileSystemNode.SelectionType, _ body: () throws -> T) rethrows -> T {
        let previous = FileSystemNode.selectionType
        FileSystemNode.selectionType = selectionType
        defer { FileSystemNode.selectionType = previous }

        return try body()
    }
}
