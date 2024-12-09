// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OSLogger",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "OSLogger",
            targets: ["OSLogger"]),
    ],
    targets: [
        .target(
            name: "OSLogger",
            dependencies: []),
        .testTarget(
            name: "OSLoggerTests",
            dependencies: ["OSLogger"]),
    ]
)
