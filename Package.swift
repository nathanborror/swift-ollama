// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ollama",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "Ollama", targets: ["Ollama"]),
    ],
    dependencies: [
        .package(url: "https://github.com/loopwork-ai/JSONSchema", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
    ],
    targets: [
        .target(name: "Ollama", dependencies: [
            .product(name: "JSONSchema", package: "JSONSchema"),
        ]),
        .executableTarget(name: "OllamaCmd", dependencies: [
            "Ollama",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
    ]
)
