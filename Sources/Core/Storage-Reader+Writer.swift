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
    var onWrite: (StorageKey) -> Void = {_ in }

    init(storage: StorageSystem,
         dependencies: DependencySystem
    ) {
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
                onWrite(key)
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
    var onWrite: (StorageKey) -> Void = {_ in }

    init(storage: StorageSystem, dependencies: DependencySystem) {
        self.storage = storage
        self.dependencies = dependencies
    }

    func write<T>(_ value: T, for key: StorageKey, onBehalf owner: StorageKey?) {
        onWrite(key)
        storage.setValue(value, for: key, onBehalf: owner)
    }
}
