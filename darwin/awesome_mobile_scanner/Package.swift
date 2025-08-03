// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "awesome_mobile_scanner",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "awesome-mobile-scanner", targets: ["awesome_mobile_scanner"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "awesome_mobile_scanner",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        )
    ]
)
