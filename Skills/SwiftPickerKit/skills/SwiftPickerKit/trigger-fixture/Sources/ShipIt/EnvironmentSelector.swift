import SwiftPickerKit

struct DeployEnvironment {
    let name: String
    let url: String
}

struct EnvironmentSelector {
    let picker: any CommandLineSelection

    func chooseEnvironment(from environments: [DeployEnvironment]) -> DeployEnvironment? {
        let names = environments.map(\.name)

        guard let chosen = picker.singleSelection(
            prompt: "Choose an environment",
            items: names,
            layout: .singleColumn,
            newScreen: true,
            showSelectedItemText: true
        ) else {
            return nil
        }

        return environments.first { $0.name == chosen }
    }
}
