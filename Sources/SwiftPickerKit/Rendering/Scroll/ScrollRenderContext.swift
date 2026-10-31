//
//  ScrollRenderContext.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct ScrollRenderContext {
    let startIndex: Int

    /// Exclusive.
    let endIndex: Int

    /// Terminal row where list content begins.
    let listStartRow: Int

    let visibleRowCount: Int
}
