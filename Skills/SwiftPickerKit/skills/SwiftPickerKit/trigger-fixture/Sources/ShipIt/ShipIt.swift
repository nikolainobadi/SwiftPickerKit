import ArgumentParser

@main
struct ShipIt: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Deploy services and clean up old release archives.",
        subcommands: [DeployCommand.self, CleanCommand.self]
    )
}
