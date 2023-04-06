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


//===----------------------------------------------------------------------===//
// MARK: - Storage
//===----------------------------------------------------------------------===//

/// Error: Storage can't provide a value for given key and type.
public struct NoValueInStorage: Error {}


/// A key-value storage that notifies about value updates.
/// Uses ``StorageKey`` to identify the value.
/// Implement this protocol when you want to persist values
/// in addition to having them in runtime memory only.
@MainActor public protocol Storage {

    /// Get `Value` in storage for a given ``StorageKey``.
    /// Throws ``NoValueInStorage`` if the value doesn't exist,
    /// or of a different type.
    func get<Value>(for key: StorageKey) throws -> Value


    /// Set a new `Value` in storage for a given key.
    func set<Value>(value: Value, for key: StorageKey)

    /// Storage must call this function for keys updated.
    @MainActor var onValueUpdate: (Set<StorageKey>) -> Void { get set }
}


@MainActor final class KeyValueStorage: Storage {
    private var values = [StorageKey: Any]()

    func get<Value>(for key: StorageKey) throws -> Value {
        guard let value = values[key] as? Value
        else { throw NoValueInStorage() }
        return value
    }

    func set<Value>(value: Value, for key: StorageKey) {
        values[key] = value
        var updatedKeys = Set<StorageKey>()
        updatedKeys.insert(key)
        onValueUpdate(updatedKeys)
    }

    var onValueUpdate: (Set<StorageKey>) -> Void = { _ in }
}


//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

@MainActor public final class StorageReader {
    let storage: Storage
    let context: Context

    init(storage: Storage, context: Context) {
        self.storage = storage
        self.context = context
    }

    func read<Value>(_ key: StorageKey) throws -> Value {
        try storage.get(for: key)
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Writer
//===----------------------------------------------------------------------===//

@MainActor public final class StorageWriter {
    let storage: Storage
    let context: Context

    init(storage: Storage, context: Context) {
        self.storage = storage
        self.context = context
    }

    func write<Value>(_ value: Value, at key: StorageKey) {
        storage.set(value: value, for: key)
    }
}

