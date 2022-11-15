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
import Combine


//===----------------------------------------------------------------------===//
// MARK: - Decision
//===----------------------------------------------------------------------===//

@MainActor public protocol Decision {

}


//===----------------------------------------------------------------------===//
// MARK: - Effect
//===----------------------------------------------------------------------===//

@MainActor public protocol Effect {

}


//===----------------------------------------------------------------------===//
// MARK: - Decision Executor Protocol
//===----------------------------------------------------------------------===//

/// Core class that combines ``StorageSystem``, ``DependencySystem`` and ``ObservationSystem`` to execute ``Decision`` and produced by it ``Effect``
@MainActor public protocol DecisionExecutor {

    /// Executes the ``Decision`` and produced by it ``Effect``s.
    /// - Parameter decision: Decision to execute
    func execute<D: Decision>(_ decision: D /*, context: Context*/)

    /// Returns a ``StorageReader`` configured for the enclosed ``StorageSystem``.
    func reader(/*context: Context*/) -> StorageReader

    /// Returns a ``StorageWriter`` configured for the enclosed ``StorageSystem``.
    func writer(/*context: Context*/) -> StorageWriter

    /// Adds provided publisher as to be notified when value at given ``StorageKey`` changes.
    func subscribe(publisher: ObservableObjectPublisher, for key: StorageKey)
}


//===----------------------------------------------------------------------===//
// MARK: - Decision Core (Default)
//===----------------------------------------------------------------------===//

// MARK: Public
public extension DecisionCore {
    func execute<D>(_ decision: D) where D : Decision {

    }

    func writer() -> StorageWriter { _writer }
    func reader() -> StorageReader { _reader }
    func subscribe(publisher: ObservableObjectPublisher, for key: StorageKey) {
        _observation.subscribe(publisher: publisher, for: key)
    }
}

// MARK: Private
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

    private var writtenKeys: Set<StorageKey> = []

    func popKeys() -> Set<StorageKey> {
        defer { writtenKeys = [] }
        return writtenKeys
    }

    func write<T>(_ value: T, for key: StorageKey, onBehalf owner: StorageKey?) {
        writtenKeys.insert(key)
        storage.setValue(value, for: key, onBehalf: owner)
    }
}
