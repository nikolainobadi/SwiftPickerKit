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
    let additionalNotes: [String]
    
    init(name: String, description: String, emoji: String, additionalNotes: [String] = []) {
        self.name = name
        self.description = description
        self.emoji = emoji
        self.additionalNotes = additionalNotes
    }
}

// MARK: - Helpers
extension TestItem {
    static let smallList: [TestItem] = [
        .init(name: "Swift", description: "Modern, safe programming language", emoji: "🔶"),
        .init(name: "Python", description: "Easy to learn, versatile language", emoji: "🐍"),
        .init(name: "JavaScript", description: "Language of the web", emoji: "💛"),
        .init(name: "Rust", description: "Memory safe, blazingly fast", emoji: "🦀"),
        .init(name: "Go", description: "Simple, efficient, and reliable", emoji: "🔵"),
        .init(name: "TypeScript", description: "JavaScript with types", emoji: "💙"),
        .init(name: "Kotlin", description: "Modern Android development", emoji: "🟣"),
        .init(name: "Ruby", description: "Programmer happiness", emoji: "💎"),
        .init(name: "C++", description: "High performance computing", emoji: "⚙️"),
        .init(name: "Java", description: "Write once, run anywhere", emoji: "☕️")
    ]

    static let largeList: [TestItem] = smallList + [
        .init(name: "C#", description: "Popular for Unity and enterprise dev", emoji: "🎮"),
        .init(name: "Haskell", description: "Pure functional programming", emoji: "📐"),
        .init(name: "Elixir", description: "Concurrent, fault-tolerant apps", emoji: "💧"),
        .init(name: "Scala", description: "FP + OOP on the JVM", emoji: "🧮"),
        .init(name: "F#", description: "Functional language in .NET", emoji: "🎼"),
        .init(name: "Lua", description: "Lightweight scripting language", emoji: "🌙"),
        .init(name: "PHP", description: "Server-side scripting powerhouse", emoji: "🐘"),
        .init(name: "R", description: "Statistics and data analysis", emoji: "📊"),
        .init(name: "Perl", description: "Practical extraction and reporting", emoji: "🦪"),
        .init(name: "Erlang", description: "Massively scalable soft real-time systems", emoji: "🟧"),
        .init(name: "Clojure", description: "Lisp on the JVM", emoji: "🍃"),
        .init(name: "Julia", description: "High performance numerical computing", emoji: "🧪"),
        .init(name: "Objective-C", description: "Classic Apple development", emoji: "🍏"),
        .init(name: "Shell", description: "Command-line scripting", emoji: "💻"),
        .init(name: "SQL", description: "Structured data querying", emoji: "🗂️"),
        .init(name: "Matlab", description: "Matrix math and engineering", emoji: "📐"),
        .init(name: "Dart", description: "Flutter’s programming language", emoji: "🎯"),
        .init(name: "Bash", description: "Unix shell scripting", emoji: "📜"),
        .init(name: "Assembly", description: "Low-level hardware control", emoji: "🧩"),
        .init(name: "Fortran", description: "Scientific and numeric computing", emoji: "📘"),
        .init(name: "Pascal", description: "Structured programming pioneer", emoji: "📙"),
        .init(name: "COBOL", description: "Legacy business systems", emoji: "🏛️"),
        .init(name: "Groovy", description: "Dynamic JVM scripting", emoji: "🎷"),
        .init(name: "Vimscript", description: "Customizing Vim editors", emoji: "🟩"),
        .init(name: "Powershell", description: "Automation for Windows", emoji: "🪟"),
        .init(name: "Solidity", description: "Smart contracts on Ethereum", emoji: "⛓️"),
        .init(name: "Prolog", description: "Logic programming", emoji: "🧠"),
        .init(name: "Lisp", description: "Code-as-data pioneer", emoji: "🔵"),
        .init(name: "Scheme", description: "Minimalist Lisp dialect", emoji: "🟥")
    ]
}

// MARK: - DynamicList
extension TestItem {
    static let dynamicList: [TestItem] = [
        .init(
            name: "Swift",
            description: "Safe, fast, modern.",
            emoji: "🔶",
            additionalNotes: [
                "Great for iOS and server apps.",
                "Built with performance and safety in mind."
            ]
        ),
        .init(
            name: "Rust",
            description: "Fearless concurrency.",
            emoji: "🦀",
            additionalNotes: [
                "Memory safety without garbage collection.",
                "Widely used for systems programming."
            ]
        ),
        .init(
            name: "Python",
            description: "Huge ecosystem.",
            emoji: "🐍",
            additionalNotes: [
                "Great for AI and automation.",
                "Very clean syntax."
            ]
        ),
        .init(
            name: "Kotlin",
            description: "Modern Android dev.",
            emoji: "🟣",
            additionalNotes: [
                "Interoperable with Java.",
                "Excellent for mobile development."
            ]
        ),
        .init(
            name: "Elixir",
            description: "Distributed systems.",
            emoji: "💧",
            additionalNotes: [
                "Built on the Erlang VM.",
                "Highly fault tolerant."
            ]
        ),
        .init(
            name: "Clojure",
            description: "A modern Lisp.",
            emoji: "🍃",
            additionalNotes: [
                "Great for data processing.",
                "Functional and expressive."
            ]
        ),
        .init(
            name: "Julia",
            description: "Scientific computing.",
            emoji: "🧪",
            additionalNotes: [
                "Designed for numerical computing.",
                "Often used in scientific communities."
            ]
        )
    ]
}

// MARK: - DisplayablePickerItem
extension TestItem: DisplayablePickerItem {
    var displayName: String {
        "\(emoji) \(name)"
    }
}
