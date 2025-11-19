//
//  SwiftPicker+CommandLinePermission.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

extension SwiftPicker: CommandLinePermission {
    public func getPermission(prompt: String) -> Bool {
        textInput.getPermission(prompt)
    }

    public func requiredPermission(prompt: String) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}
