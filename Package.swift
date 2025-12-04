// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPickerKit",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SwiftPickerKit",
            targets: ["SwiftPickerKit"]),
        .library(
            name: "SwiftPickerTesting",
            targets: ["SwiftPickerTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/ANSITerminalModified", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "SwiftPickerKit",
            dependencies: [
                .product(name: "ANSITerminal", package: "ANSITerminalModified")
            ]
        ),
        .target(
            name: "SwiftPickerTesting",
            dependencies: ["SwiftPickerKit"]
        ),
        .testTarget(
            name: "SwiftPickerKitTests",
            dependencies: [
                "SwiftPickerKit",
                "SwiftPickerTesting"
            ]
        ),
    ]
)
