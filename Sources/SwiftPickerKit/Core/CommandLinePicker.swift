//
//  CommandLinePicker.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/18/25.
//

/// Unified protocol combining all SwiftPicker command-line interaction APIs.
public typealias CommandLinePicker = CommandLineInput
    & CommandLinePermission
    & CommandLineSelection
    & CommandLineTreeNavigation
