// swift-tools-version:5.9
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
import CompilerPluginSupport

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
    ],
    targets: [
        .target(
            name: "Decide",
            path: "Decide"
        ),
        .testTarget(
            name: "Decide-Tests",
            dependencies: [
                "Decide"
            ],
            path: "Decide-Tests"
        ),
    ]
)
