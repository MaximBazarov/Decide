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


/// A unique identifier of the state for the ``StorageSystem``
public enum StorageKey: Hashable {
    case atom(ObjectIdentifier)
    case group(ObjectIdentifier, AnyHashable)
    case computation(ObjectIdentifier)
    case groupComputation(ObjectIdentifier, AnyHashable)
}


/// Provides read/write access to the values by given ``StorageKey``
public protocol StorageSystem: Actor {

    /// Returns the value stored in the ``StorageSystem``
    /// - Parameters:
    ///   - key: key of the desired value
    ///   - ownerKey: key of the reader of the value e.g when computation accesses the value, that computation will be the owner.
    ///   - defaultValue: a value that is returned when there's no value in the ``StorageSystem`` for a given ``StorageKey``.
    /// - Returns: value of the state.
    nonisolated func getValue<V>(
        for key: StorageKey,
        onBehalf ownerKey: StorageKey?,
        defaultValue: () -> V
    ) -> V

    /// Writes the value into the storage of the ``StorageSystem``.
    /// - Parameters:
    ///   - value: value to write
    ///   - key: key for which the value should be written.
    ///   - ownerKey: key of the writer of the value e.g when computation accesses the value, that computation will be the owner.
    nonisolated func setValue<V>(
        _ value: V,
        for key: StorageKey,
        onBehalf ownerKey: StorageKey?
    )
}



/// ``StorageSystem`` with automatic dependency graph building:
/// - When key is read, the owner of this read will be marked as dependent on the key. Every time the value at the `key` changes, the value of the `owner` will be invalidated. Check ``StorageSystem/getValue(for:onBehalf:defaultValue:)`` for details.
///
actor Storage: StorageSystem {
    nonisolated func getValue<V>(for key: StorageKey, onBehalf ownerKey: StorageKey?, defaultValue: () -> V) -> V {
        fatalError()
    }

    nonisolated func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?) {
        fatalError()
    }
}
