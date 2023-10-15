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
import OSLog

/// ApplicationEnvironment stores instances of ``AtomicStorage`` and ``KeyedStorage`` and provides tools for mutations and asynchronous executions of side-effects.
@MainActor public final class ApplicationEnvironment {

    static let _subsystem = "Decide App Environment"
    let _decisionLog = Logger(
        subsystem: _subsystem,
        category: "Decision"
    )
    let _effectLog = Logger(
        subsystem: _subsystem,
        category: "Effect"
    )

    enum Key: Hashable {
        case atomic(ObjectIdentifier)
        case keyed(ObjectIdentifier, AnyHashable)
    }

    static let `default` = ApplicationEnvironment()

    var storage: [Key: Any] = [:]

    func storage<Storage: ObservableStateStorage>(_ key: Key) -> Storage {
        if let state = storage[key] as? Storage {
            return state
        }
        let newValue = Storage.init()
        storage[key] = newValue
        return newValue
    }

    func observableState<Storage: AtomicStorage, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>
    ) -> ObservableState<Value> {
        let state: Storage = storage(Storage.key())
        return state[keyPath: keyPath]
    }

    func observableState<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        at id: Identifier
    ) -> ObservableState<Value> {
        let state: Storage = storage(Storage.key(id))
        return state[keyPath: keyPath]
    }

    public init() {}
}

