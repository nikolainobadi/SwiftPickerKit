//
//  SwiftPicker+CommandLinePermission.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

extension SwiftPicker: CommandLinePermission {
    /// Returns `true` without asking when the picker was created with `assumeYes: true`.
    public func getPermission(prompt: String) -> Bool {
        return assumeYes || textInput.getPermission(prompt)
    }
}
