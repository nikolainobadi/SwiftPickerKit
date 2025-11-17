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
}

// MARK: - Lists
extension TestItem {

    // Small list
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

    // Large list: includes smallList + many more
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

extension TestItem: DisplayablePickerItem {
    var displayName: String {
        "\(emoji) \(name)"
    }
}
