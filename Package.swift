// swift-tools-version:5.7
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
import PackageDescription

let package = Package(
    name: "Decide",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15),
    ],
    products: [
        .library(name: "Decide", targets: ["Decide"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MaximBazarov/Inject.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Decide",
            dependencies: ["Inject"],
            path: "Sources"
        ),
        .testTarget(
            name: "Decide-Tests",
            dependencies: ["Decide", "Inject"],
            path: "Tests"
        )
    ]
)
