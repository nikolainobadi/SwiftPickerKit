import ArgumentParser
import Foundation

struct DeployCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "deploy",
        abstract: "Upload services to an environment."
    )

    @Option(name: .long, help: "staging or production")
    var env: String?

    func run() throws {
        let environment = env ?? askForEnvironment()

        print("Services to deploy (comma-separated: api, web, worker, scheduler):", terminator: " ")
        let services = (readLine() ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        print("API token:", terminator: " ")
        let token = readLine() ?? ""

        print("Deploy \(services.count) service(s) to \(environment)? (y/n)", terminator: " ")
        guard readLine()?.lowercased() == "y" else {
            return
        }

        for service in services {
            try Uploader(token: token).upload(service: service, to: environment)
        }

        print("Done.")
    }

    private func askForEnvironment() -> String {
        print("Environment (type staging or production):", terminator: " ")
        return readLine() ?? "staging"
    }
}

struct Uploader {
    let token: String

    func upload(service: String, to environment: String) throws {
        // Network upload; takes several seconds per service.
        Thread.sleep(forTimeInterval: 3)
    }
}
