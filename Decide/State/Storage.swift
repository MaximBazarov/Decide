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

import Foundation

@MainActor protocol ObservableStateStorage {
    init()
}

/// AtomicStorage is a managed by ``ApplicationEnvironment`` container for ``ObservableState`` and ``DefaultInstance`` definitions,
/// its only requirement is to provide standalone `init()` so ``ApplicationEnvironment`` can instantiate it when necessary.
/// You should never use instances of ``AtomicStorage`` directly, use ``ObservableState`` or ``DefaultInstance`` instead.
///
/// **Usage:**
/// ```swift
/// final class TestState: AtomicStorage {
///     // Declaration of a AtomicStorage observableState with a string value
///     // that is "default-value" by default.
///     @ObservableState var name: String = "default-value"
///
///     // Declaration of the instance of a `NetworkingInterface` protocol
///     // that is `Networking()` by default.
///     @DefaultInstance var networking: NetworkingInterface = Networking()
/// }
/// ```
@MainActor open class AtomicStorage: ObservableStateStorage {
    required public init() {}

    static func key() -> ApplicationEnvironment.Key {
        .atomic(ObjectIdentifier(self))
    }
}

/// KeyedStorage is a collection of ``AtomicStorage`` accessed by `Identifier`.
///
/// **Usage:**
/// ```swift
/// final class TestKeyedState: KeyedStorage<UUID> {
///     @ObservableState var name: String = "default-value"
/// }
///
/// ```
/// to access the state `Identifier` will have to be provided together with ``ObservableState`` KeyPath.
@MainActor open class KeyedStorage<Identifier: Hashable>: ObservableStateStorage {
    required public init() {}

    static func key(_ identifier: Identifier) -> ApplicationEnvironment.Key {
        .keyed(ObjectIdentifier(self), identifier)
    }
}
