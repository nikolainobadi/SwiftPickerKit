//
//  ScrollLayout.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct ScrollLayout {
    let rows: Int
    let headerHeight: Int
    let footerHeight: Int
    
    var availableListRows: Int {
        return rows - headerHeight - footerHeight
    }
}
