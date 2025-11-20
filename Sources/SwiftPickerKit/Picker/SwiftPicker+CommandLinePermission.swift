//
//  SwiftPicker+CommandLinePermission.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

extension SwiftPicker: CommandLinePermission {
    public func getPermission(prompt: String) -> Bool {
        return textInput.getPermission(prompt)
    }
}
