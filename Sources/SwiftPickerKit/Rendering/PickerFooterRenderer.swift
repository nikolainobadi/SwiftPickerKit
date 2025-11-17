//
//  PickerFooterRenderer.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct PickerFooterRenderer {
    private let pickerInput: PickerInput
    
    /// Height of the footer block (number of rows)
    /// Adjust if you add more lines
    private let footerHeight: Int = 3   // ↓ arrow / blank / instructions
    
    init(pickerInput: PickerInput) {
        self.pickerInput = pickerInput
    }
}
 
extension PickerFooterRenderer {
    func height() -> Int {
        return footerHeight
    }
    
    /// Renders the footer anchored at the bottom of the terminal window.
    /// Replaces any content previously in the footer region.
    func renderFooter(
        showScrollDownIndicator: Bool,
        instructionText: String
    ) {
        let (rows, _) = pickerInput.readScreenSize()
        let startRow = max(0, rows - footerHeight)
        
        // Move cursor to the footer region
        pickerInput.moveTo(startRow, 0)
        
        // Clear footer region
        for _ in 0..<footerHeight {
            pickerInput.write("\u{1B}[2K")    // clear line
            pickerInput.write("\n")
        }
        
        // Return again to render footer lines
        pickerInput.moveTo(startRow, 0)
        
        // DOWN ARROW (if needed)
        if showScrollDownIndicator {
            pickerInput.write("↓".lightGreen + "\n")
        } else {
            pickerInput.write("\n")
        }
        
        // BLANK LINE
        pickerInput.write("\n")
        
        // INSTRUCTION TEXT
        pickerInput.write(instructionText)
    }
}
