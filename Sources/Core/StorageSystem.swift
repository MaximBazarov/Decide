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
// MARK: - Storage System
//===----------------------------------------------------------------------===//

/// Provides read/write access to the values by given ``StorageKey``.
///
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

    @MainActor func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?)
}

//===----------------------------------------------------------------------===//
// MARK: - Value Provider
//===----------------------------------------------------------------------===//

/// Provides a default value of type `T`
public typealias ValueProvider<T> = @MainActor () -> T

//===----------------------------------------------------------------------===//
// MARK: - In-memory Storage (Default)
//===----------------------------------------------------------------------===//

@MainActor final class InMemoryStorage: StorageSystem {
    public func getValue<T>(for key: StorageKey, onBehalf ownerKey: StorageKey?) throws -> T {
        guard values.keys.contains(key) else { throw NoValueInStorage(key) }
        guard let value = values[key] as? T else { throw ValueTypeMismatch(key) }
        return value
    }

    public func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?) {
        values[key] = value
    }

    // MARK: Values
    private var values: [StorageKey: Any] = [:]
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
