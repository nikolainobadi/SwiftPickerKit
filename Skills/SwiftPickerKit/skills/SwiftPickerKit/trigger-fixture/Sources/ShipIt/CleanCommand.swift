import ArgumentParser
import Foundation

struct CleanCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "clean",
        abstract: "Delete an old release archive folder."
    )

    func run() throws {
        print("Path to the archive folder to delete:", terminator: " ")
        let path = readLine() ?? ""

        guard !path.isEmpty else {
            throw ValidationError("No folder given.")
        }

        try FileManager.default.removeItem(atPath: path)
        print("Deleted \(path)")
    }
}
