// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Decide",
    platforms: [
        .macOS(.v14),
        .iOS(.v15),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "Decide",
            targets: ["Decide"]
        ),
    ],
    targets: [
        .target(
            name: "Decide",
            path: "Sources"
        ),
        .testTarget(
            name: "Decide_Tests",
            dependencies: ["Decide"],
            path: "Tests"
        ),
    ]
)
