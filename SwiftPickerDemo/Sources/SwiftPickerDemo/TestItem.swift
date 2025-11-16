//
//  TestItem.swift
//  SwiftPickerDemo
//
//  Created by Nikolai Nobadi on 11/16/25.
//

import SwiftPickerKit

struct TestItem {
    let name: String
    let description: String
    let emoji: String

    static let sampleItems: [TestItem] = [
        TestItem(name: "Swift", description: "Modern, safe programming language", emoji: "🔶"),
        TestItem(name: "Python", description: "Easy to learn, versatile language", emoji: "🐍"),
        TestItem(name: "JavaScript", description: "Language of the web", emoji: "💛"),
        TestItem(name: "Rust", description: "Memory safe, blazingly fast", emoji: "🦀"),
        TestItem(name: "Go", description: "Simple, efficient, and reliable", emoji: "🔵"),
        TestItem(name: "TypeScript", description: "JavaScript with types", emoji: "💙"),
        TestItem(name: "Kotlin", description: "Modern Android development", emoji: "🟣"),
        TestItem(name: "Ruby", description: "Programmer happiness", emoji: "💎"),
        TestItem(name: "C++", description: "High performance computing", emoji: "⚙️"),
        TestItem(name: "Java", description: "Write once, run anywhere", emoji: "☕️")
    ]
}

extension TestItem: DisplayablePickerItem {
    var displayName: String {
        "\(emoji) \(name)"
    }
}
