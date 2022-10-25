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

//===----------------------------------------------------------------------===//
// MARK: - In-memory Storage
//===----------------------------------------------------------------------===//

@MainActor public final class InMemoryStorage: StorageSystem {
    public var storageReader: StorageReader { StorageReader(storage: self) }
    public var storageWriter: StorageWriter { StorageWriter(storage: self) }

    private var values: [StorageKey: Any] = [:]

    public func getValue<T>(for key: StorageKey, onBehalf ownerKey: StorageKey?) throws -> T {
        guard values.keys.contains(key) else { throw NoValueInStorage(key) }
        guard let value = values[key] as? T else { throw ValueTypeMismatch(key) }
        return value
    }

    public func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?) {
        values[key] = value
    }

    public func didUpdateKeys(_ keys: inout Set<StorageKey>) {
        // notify observers
    }
}
