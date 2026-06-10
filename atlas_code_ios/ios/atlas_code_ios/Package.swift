// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "atlas_code_ios",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "atlas-code-ios", targets: ["atlas_code_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "atlas_code_ios",
            dependencies: []
        )
    ]
)
