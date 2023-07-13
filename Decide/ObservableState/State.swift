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

@MainActor protocol State: AnyObject {
    init()
}

/// AtomicState is a managed by ``StateEnvironment`` container for ``Property`` and ``DefaultInstance`` definitions,
/// its only requirement is to provide standalone `init()` so ``StateEnvironment`` can instantiate it when necessary.
/// You should never use instances of ``AtomicState`` directly, use ``Property`` or ``DefaultInstance`` instead.
///
/// **Usage:**
/// ```swift
/// final class TestState: AtomicState {
///     // Declaration of a AtomicState property with a string value
///     // that is "default-value" by default.
///     @Property var name: String = "default-value"
///
///     // Declaration of the instance of a `NetworkingInterface` protocol
///     // that is `Networking()` by default.
///     @DefaultInstance var networking: NetworkingInterface = Networking()
/// }
/// ```
@MainActor open class AtomicState: State {
    required public init() {}
}

/// KeyedState is a collection of ``AtomicState`` accessed by `Identifier`.
///
/// **Usage:**
/// ```swift
/// final class TestKeyedState: KeyedState<UUID> {
///     @Property var name: String = "default-value"
///     @DefaultInstance var networking: NetworkingInterface = Networking()
/// }
///
/// ```
/// to access the state `Identifier` will have to be provided together with ``Property`` KeyPath.
@MainActor open class KeyedState<Identifier: Hashable>: State {
    required public init() {}
}
