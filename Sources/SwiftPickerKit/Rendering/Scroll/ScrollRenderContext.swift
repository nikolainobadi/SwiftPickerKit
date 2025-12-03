//
//  ScrollRenderContext.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

struct ScrollRenderContext {
    /// First visible item index in the data set
    let startIndex: Int

    /// One past the last visible item index
    let endIndex: Int

    /// First terminal row where list content should be rendered
    let listStartRow: Int

    /// Number of rows available for list content
    let visibleRowCount: Int
}
