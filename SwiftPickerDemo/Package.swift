// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPickerDemo",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftPickerDemo",
            dependencies: [
                .product(name: "SwiftPickerKit", package: "SwiftPickerKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
