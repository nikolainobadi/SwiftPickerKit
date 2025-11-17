//
//  ScrollRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct ScrollRenderer {
    private let pickerInput: PickerInput

    init(pickerInput: PickerInput) {
        self.pickerInput = pickerInput
    }

    func renderUpArrow(at row: Int) {
        pickerInput.moveTo(row, 0)
        pickerInput.write("↑".lightGreen)
    }

    func renderDownArrow(at row: Int) {
        pickerInput.moveTo(row, 0)
        pickerInput.write("↓".lightGreen)
    }
}
