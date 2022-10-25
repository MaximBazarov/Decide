//
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

import Foundation
import Inject

//===----------------------------------------------------------------------===//
// MARK: - Storage Key
//===----------------------------------------------------------------------===//

/// A unique identifier of the state for the ``StorageSystem``
public enum StorageKey: Hashable {
    case atom(ObjectIdentifier)
    case collectionElement(ObjectIdentifier, AnyHashable)
}

//===----------------------------------------------------------------------===//
// MARK: - Storage System
//===----------------------------------------------------------------------===//

/// Provides read/write access to the values by given ``StorageKey``
/// Storage read/write operations must be performed on `@MainActor`
public protocol StorageSystem {

    /// Returns the value stored in the ``StorageSystem``
    /// - Parameters:
    ///   - key: key of the desired value
    ///   - ownerKey: key of the reader of the value e.g when computation accesses the value, that computation will be the owner.
    ///   - defaultValue: a value that is returned when there's no value in the ``StorageSystem`` for a given ``StorageKey``.
    /// - Returns: value of the state.
    @MainActor func getValue<T>(
        for key: StorageKey,
        onBehalf ownerKey: StorageKey?
    ) throws -> T

    /// Report to storage that keys were updated, so it can notify the observers or do any other required operation after a set of keys is written
    @MainActor func didUpdateKeys(_ keys: inout Set<StorageKey>)

    /// Must return a ``StorageReader`` for itself.
    @MainActor var storageReader: StorageReader { get }

    /// Must return a ``StorageWriter`` for itself.
    @MainActor var storageWriter: StorageWriter { get }
}

//===----------------------------------------------------------------------===//
// MARK: - Default Value Provider
//===----------------------------------------------------------------------===//

/// Provides a default value of type `T`
public typealias DefaultValueProvider<T> = @MainActor () -> T

//===----------------------------------------------------------------------===//
// MARK: - In-memory Storage
//===----------------------------------------------------------------------===//

@MainActor public final class InMemoryStorage: StorageSystem {
    // MARK: Interface
    public var storageReader: StorageReader { StorageReader(storage: self) }
    public var storageWriter: StorageWriter { StorageWriter(storage: self) }

    public func getValue<T>(for key: StorageKey, onBehalf ownerKey: StorageKey?) throws -> T {
        guard values.keys.contains(key) else { throw NoValueInStorage(key) }
        guard let value = values[key] as? T else { throw ValueTypeMismatch(key) }
        return value
    }

    public func didUpdateKeys(_ keys: inout Set<StorageKey>) {
        // notify observers
    }

    // MARK: Values
    private var values: [StorageKey: Any] = [:]

    private func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?) {
        values[key] = value
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Storage Reader
//===----------------------------------------------------------------------===//

/// Reads the value from the storage at the provided key.
/// ```swift
/// // read: StorageReader
/// let x = read(SomeState.self)
/// // x: SomeState.Value
/// ```
@MainActor public final class StorageReader {
    var storage: StorageSystem
    var writtenDefaultValues: [StorageKey: Any] = [:]

    public init(storage: StorageSystem) {
        self.storage = storage
    }

    func read<T>(
        key: StorageKey,
        onBehalf ownerKey: StorageKey?,
        defaultValue: DefaultValueProvider<T>
    ) -> T {
        do {
            return try storage.getValue(
                for: key,
                onBehalf: ownerKey
            )
        } catch {
            let newValue = defaultValue()
            writtenDefaultValues[key] = newValue
            return newValue
        }
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Storage Writer
//===----------------------------------------------------------------------===//

/// Writes the value into the storage for a provided key.
/// ```swift
/// // write: StorageWriter
/// write(x, into: SomeState.self)
/// ```
@MainActor public final class StorageWriter {
    var storage: StorageSystem

    public init(storage: StorageSystem) {
        self.storage = storage
    }

    private var writtenKeys: [StorageKey] = []

    func popKeys() -> [StorageKey] {
        defer { writtenKeys = [] }
        return writtenKeys
    }

    func write<T>(_ value: T, for key: StorageKey, onBehalf owner: StorageKey?) {
        writtenKeys.append(key)
        storage.setValue(value, for: key, onBehalf: owner)
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Errors
//===----------------------------------------------------------------------===//

/// Storage doesn't contain a value for the given key
public final class NoValueInStorage: Error {
    public let key: StorageKey
    init(_ key: StorageKey) {
        self.key = key
    }
}

/// Value from storage can't be casted to expected type.
public final class ValueTypeMismatch: Error {
    public let key: StorageKey
    init(_ key: StorageKey) {
        self.key = key
    }
}
