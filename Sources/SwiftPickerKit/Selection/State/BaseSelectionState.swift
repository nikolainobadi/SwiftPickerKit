//
//  BaseSelectionState.swift
//  SwiftPickerKit
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// Base protocol for selection state, allowing different state implementations
/// (single-column, two-column, etc.) to work with the same behaviors and handlers.
protocol BaseSelectionState<Item> {
    associatedtype Item: DisplayablePickerItem

    var activeIndex: Int { get set }
    var options: [Option<Item>] { get }
    var prompt: String { get }
    var topLineText: String { get }
    var bottomLineText: String { get }
    var selectedDetailLines: [String] { get }
    var showSelectedItemText: Bool { get }

    func toggleSelection(at index: Int)
}

extension BaseSelectionState {
    var selectedDetailLines: [String] { [] }
    var showSelectedItemText: Bool { true }

    func toggleSelection(at index: Int) { }
}
