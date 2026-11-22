import Testing
import Foundation
@testable import SwiftPickerKit

@Suite(.signalState)
struct FileSystemNodeTests {
    @Test
    func `Only folders hides files from loaded children`() throws {
        let (sut, directory) = try makeSUT()
        defer { try? FileManager.default.removeItem(at: directory) }

        let names = FileSystemFixture.withSelectionType(.onlyFolders) {
            sut.loadChildren().map(\.displayName)
        }

        #expect(names == ["b-folder", "d-folder"])
    }

    @Test
    func `Only files still lists folders so files inside stay reachable`() throws {
        let (sut, directory) = try makeSUT()
        defer { try? FileManager.default.removeItem(at: directory) }

        let names = FileSystemFixture.withSelectionType(.onlyFiles) {
            sut.loadChildren().map(\.displayName)
        }

        #expect(names == ["a-file.txt", "b-folder", "c-file.txt", "d-folder"])
    }

    @Test
    func `Files and folders lists every visible item`() throws {
        let (sut, directory) = try makeSUT()
        defer { try? FileManager.default.removeItem(at: directory) }

        let names = FileSystemFixture.withSelectionType(.filesAndFolders) {
            sut.loadChildren().map(\.displayName)
        }

        #expect(names == ["a-file.txt", "b-folder", "c-file.txt", "d-folder"])
    }
}

// MARK: - SUT
private extension FileSystemNodeTests {
    func makeSUT() throws -> (sut: FileSystemNode, directory: URL) {
        let directory = try FileSystemFixture.makeMixedDirectory()

        return (FileSystemNode(url: directory), directory)
    }
}
