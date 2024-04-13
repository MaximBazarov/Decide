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
        .library(
            name: "DecideUI",
            targets: ["DecideUI"]
        ),
    ],
    targets: [
        // MARK: - Decide Core -

        .target(
            name: "Decide",
            path: "DecideCore/Sources"
        ),
        .testTarget(
            name: "Decide_Tests",
            dependencies: ["Decide"],
            path: "DecideCore/Tests"
        ),

        // MARK: - Decide UI -

        .target(
            name: "DecideUI",
            dependencies: ["Decide"],
            path: "DecideUI/Sources"
        ),
        .testTarget(
            name: "DecideUI_Tests",
            dependencies: ["DecideUI"],
            path: "DecideUI/Tests"
        ),
    ]
)
