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

import Inject

@MainActor public protocol Decision {}
@MainActor public protocol Effect {}

//===----------------------------------------------------------------------===//
// MARK: - Decision Executor Protocol
//===----------------------------------------------------------------------===//

/// Executes decisions ``Decision``
@MainActor public protocol DecisionExecutor {
    func reader(/*context: Context*/) -> StorageReader
    func writer(/*context: Context*/) -> StorageWriter
    func execute<D: Decision>(_ decision: D /*, context: Context*/)
    var observation: ObservationSystem { get }
}

//===----------------------------------------------------------------------===//
// MARK: - Decision Core Public interface
//===----------------------------------------------------------------------===//
public extension DecisionCore {
    var observation: ObservationSystem { _observation }
    func execute<D>(_ decision: D) where D : Decision {}
    func writer() -> StorageWriter { _writer }
    func reader() -> StorageReader { _reader }
}

//===----------------------------------------------------------------------===//
// MARK: - Decision Core (Default)
//===----------------------------------------------------------------------===//
@MainActor public final class DecisionCore: DecisionExecutor {
    let _storage: StorageSystem
    let _dependencies: DependencySystem
    let _observation: ObservationSystem
    let _reader: StorageReader
    let _writer: StorageWriter

    init(storage: StorageSystem? = nil,
         dependencies: DependencySystem? = nil,
         observation: ObservationSystem? = nil
    ) {
        let storage = storage ?? InMemoryStorage()
        let dependencies = dependencies ?? DependencyGraph()
        let observation = observation ?? ObservationSystem()
        _storage = storage
        _dependencies = dependencies
        _observation = observation
        _reader = StorageReader(storage: storage, dependencies: dependencies)
        _writer = StorageWriter(storage: storage, dependencies: dependencies)
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
    var dependencies: DependencySystem

    init(storage: StorageSystem, dependencies: DependencySystem) {
        self.storage = storage
        self.dependencies = dependencies
    }

    func read<T>(
        key: StorageKey,
        onBehalf ownerKey: StorageKey?,
        fallbackValue: ValueProvider<T>,
        shouldStoreDefaultValue: Bool
    ) -> T {
        do {
            if let owner = ownerKey, key != owner {
                dependencies.add(dependency: owner, thatInvalidates: key)
            }

            return try storage.getValue(
                for: key,
                onBehalf: ownerKey
            )
        } catch {
            let newValue = fallbackValue()
            if shouldStoreDefaultValue {
                storage.setValue(newValue, for: key, onBehalf: key)
            }
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
    var dependencies: DependencySystem

    init(storage: StorageSystem, dependencies: DependencySystem) {
        self.storage = storage
        self.dependencies = dependencies
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
