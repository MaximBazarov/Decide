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

/// State is a managed by ``Environment`` container for ``Property`` and ``DefaultInstance`` definitions,
/// its only requirement is to provide standalone `init()` so ``Environment`` can instantiate it when necessary.
/// You should never use instances of ``State`` directly, use ``Property`` or ``DefaultInstance`` instead.
///
/// **Usage:**
/// ```swift
/// final class TestState: StateManagement.State {
///     // Declaration of a State property with a string value
///     // that is "default-value" by default.
///     @Property var name: String = "default-value"
///
///     // Declaration of the instance of a `NetworkingInterface` protocol
///     // that is `Networking()` by default.
///     @DefaultInstance var networking: NetworkingInterface = Networking()
/// }
/// ```
@MainActor public protocol State: AnyObject {
    init()
}
