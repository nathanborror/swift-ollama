// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OllamaKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "OllamaKit", targets: ["OllamaKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nathanborror/SharedKit", branch: "main"),
    ],
    targets: [
        .target(name: "OllamaKit", dependencies: [
            .product(name: "SharedKit", package: "SharedKit"),
        ]),
        .testTarget(name: "OllamaKitTests", dependencies: ["OllamaKit"]),
    ]
)
