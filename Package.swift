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
        .library(name: "DecideTesting", targets: ["DecideTesting"]),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "Decide",
            dependencies: [
                "DecideMacros"
            ],
            path: "Decide"
        ),
        .macro(
            name: "DecideMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "DecideMacros"
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
        // Macros Tests
        .testTarget(
            name: "DecideMacros-Tests",
            dependencies: [
                "Decide",
                "DecideMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "DecideMacros-Tests"
        ),
    ]
)
