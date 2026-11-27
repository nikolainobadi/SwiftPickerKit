// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ShipIt",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/nikolainobadi/SwiftPickerKit.git", from: "0.15.0"),
    ],
    targets: [
        .executableTarget(
            name: "ShipIt",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftPickerKit", package: "SwiftPickerKit"),
            ]
        ),
        .testTarget(
            name: "ShipItTests",
            dependencies: ["ShipIt"]
        ),
    ]
)
