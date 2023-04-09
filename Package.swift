// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Vice",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .executable(name: "vice", targets: ["Vice"]),
        .executable(name: "task", targets: ["ViceTasks"]),
        .library(name: "Jaws", targets: ["Jaws"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", .upToNextMinor(from: "0.39.1")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/JohnSundell/Files.git", .upToNextMinor(from: "4.2.0")),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", .upToNextMinor(from: "2.3.0")),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", .upToNextMinor(from: "0.44.4"))
    ],
    targets: [
        .executableTarget(
            name: "ViceTasks",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ShellOut", package: "ShellOut")
            ]),
        .executableTarget(
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
 
