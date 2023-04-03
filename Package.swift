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
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15),
    ],
    products: [
        .library(name: "Decide", targets: ["Decide"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Decide",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "Decide-Tests",
            dependencies: ["Decide"],
            path: "Tests"
        )
    ]
)
