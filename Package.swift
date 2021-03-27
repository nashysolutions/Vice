// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Vice",
    platforms: [.macOS(.v10_13)],
    products: [
        .executable(name: "vice", targets: ["Vice"]),
        .library(name: "Jaws", targets: ["Jaws"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/JohnSundell/Files.git", .upToNextMinor(from: "4.2.0")),
    ],
    targets: [
        .target(
            name: "Vice",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files"),
                .target(name: "Jaws")
            ]),
        .target(
            name: "Jaws",
            dependencies: [
                .product(name: "Files", package: "Files")
            ]),
        .testTarget(
            name: "JawsTests",
            dependencies: [
                .product(name: "Files", package: "Files"),
                .target(name: "Jaws")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
