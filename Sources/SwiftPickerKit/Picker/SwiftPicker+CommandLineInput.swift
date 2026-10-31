//
//  SwiftPicker+CommandLineInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

extension SwiftPicker: CommandLineInput {
    public func getInput(prompt: String) -> String {
        return textInput.getInput(prompt)
    }

    public func getSecretInput(prompt: String) -> String {
        let input = textInput.getSecretInput(prompt)

        if SignalHandler.wasInterrupted {
            waitForTermination?()
        }

        return input
    }
}
