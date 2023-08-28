// swift-tools-version:5.7
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "Decide",
    platforms: [
        .macOS(.v13),
        .iOS(.v14),
        .watchOS(.v8),
        .tvOS(.v15),
    ],
    products: [
        .library(name: "Decide", targets: ["Decide"]),
        .library(name: "DecideTesting", targets: ["DecideTesting"]),
    ],
    dependencies: [
    ],
    targets: [
        // - Decide -
        .target(
            name: "Decide",
            dependencies: [],
            path: "Decide"
        ),
        .testTarget(
            name: "Decide-Tests",
            dependencies: [
                "Decide",
                "DecideTesting"
            ],
            path: "Decide-Tests"
        ),
        // - Decide Testing -
        .target(
            name: "DecideTesting",
            dependencies: ["Decide"],
            path: "DecideTesting"
        ),
    ]
)
