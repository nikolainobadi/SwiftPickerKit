//
//  DefaultPickerInput.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import ANSITerminal

struct DefaultPickerInput: PickerInput {
    func cursorOff() {
        ANSITerminal.cursorOff()
    }
    
    func moveRight() {
        ANSITerminal.moveRight()
    }
    
    func moveToHome() {
        ANSITerminal.moveToHome()
    }
    
    func clearBuffer() {
        ANSITerminal.clearBuffer()
    }
    
    func clearScreen() {
        ANSITerminal.clearScreen()
    }
    
    func enableNormalInput() {
        ANSITerminal.cursorOn()
        ANSITerminal.restoreDefaultTerminal()
    }
    
    func keyPressed() -> Bool {
        return ANSITerminal.keyPressed()
    }
    
    func write(_ text: String) {
        ANSITerminal.write(text)
    }
    
    func exitAlternativeScreen() {
        ANSITerminal.exitAlternativeScreen()
    }
    
    func enterAlternativeScreen() {
        ANSITerminal.enterAlternativeScreen()
    }
    
    func moveTo(_ row: Int, _ col: Int) {
        ANSITerminal.moveTo(row, col)
    }
    
    func readCursorPos() -> (row: Int, col: Int) {
        return ANSITerminal.readCursorPos()
    }
    
    func readScreenSize() -> (rows: Int, cols: Int) {
        return ANSITerminal.readScreenSize()
    }
    
    func readDirectionKey() -> Direction? {
        switch ANSITerminal.readKey().code {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        default:
            return nil
        }
    }
    
    func readSpecialChar() -> SpecialChar? {
        let char = ANSITerminal.readChar()
        if char == NonPrintableChar.enter.char() {
            return .enter
        }
        
        if char == " " {
            return .space
        }
        
        if char == "q" || char == "Q" {
            return .quit
        }
        if char == "\u{7F}" {
            return .backspace
        }
        
        return nil
    }
}
