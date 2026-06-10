// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "atlas_code_macos",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "atlas-code-macos", targets: ["atlas_code_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "atlas_code_macos",
            dependencies: []
        )
    ]
)
