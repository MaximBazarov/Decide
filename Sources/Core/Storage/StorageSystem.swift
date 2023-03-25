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
import OSLog
import SwiftUI

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
        onBehalf ownerKey: StorageKey?,
        context: Context
    ) throws -> T

    @MainActor func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?, context: Context)
    @MainActor func invalidate(keys: Set<StorageKey>, changed: StorageKey)
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

    var telemetry: Telemetry?
    var telemetryLevels: Set<TelemetryLevel> = []

    public func getValue<T>(for key: StorageKey, onBehalf ownerKey: StorageKey?, context: Context) throws -> T {
        let end = telemetry?.readStart(key: key, owner: ownerKey)
        defer { end?() }
        guard values.keys.contains(key) else { throw NoValueInStorage(key) }
        guard let value = values[key] as? T else { throw ValueTypeMismatch(key) }
        telemetry?.storage(self, reads: value, from: key, ownerKey: ownerKey)
        return value
    }



    public func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?, context: Context) {
        let end = telemetry?.writeStart(key: key, owner: ownerKey, context: context)
        defer { end?() }
        telemetry?.storage(self, writes: value, into: key, ownerKey: ownerKey)
        values[key] = value
    }

    @MainActor func invalidate(keys: Set<StorageKey>, changed: StorageKey) {
        let end = telemetry?.invalidateDependenciesStart(keys: keys, key: changed)
        defer { end?() }
        telemetry?.storage(self, invalidates: keys)
        keys.forEach { key in
            values.removeValue(forKey: key)
        }
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

//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//

private extension Telemetry {
    static var storageOperations: StaticString { "Storage" }

    @MainActor func invalidateDependenciesStart(keys: Set<StorageKey>, key: StorageKey) -> () -> Void {
        let name = Self.storageOperations
        let state = signposter.beginInterval(
            name,
            id: id,
            "invalidate: \(key.debugDescription, privacy: .private(mask: .hash)), dependencies: \(keys.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }

    @MainActor func readStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let name = Self.storageOperations
        let state = signposter.beginInterval(
            name,
            id: id,
            "read: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }

    @MainActor func writeStart(key: StorageKey, owner: StorageKey?, context: Context) -> () -> Void {
        let name = Self.storageOperations
        let state = signposter.beginInterval(
            name,
            id: id,
            "write: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))\n\(context.debugDescription)"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Logging
    //===----------------------------------------------------------------------===//

    @MainActor
    func storage<S: AnyObject, V>(_ storage: S, reads value: V, from key: StorageKey, ownerKey: StorageKey?) {
        // logger is a Logger class object
        logger.trace("""
        [Storage] \(ObjectIdentifier(storage).debugDescription):
        \n\t returns: \(String(describing: value))
        \n\t for key: \(key.debugDescription)
        \nowner: \(ownerKey?.debugDescription ?? "", privacy: .private(mask: .hash))
        """)
    }

    @MainActor
    func storage<S: AnyObject, V>(_ storage: S, writes value: V, into key: StorageKey, ownerKey: StorageKey?) {
        // logger is a Logger class object
        logger.trace("""
        [Storage] \(ObjectIdentifier(storage).debugDescription):
        \n\t writes: \(String(describing: value))
        \n\t into key: \(key.debugDescription)
        \n owner: \(ownerKey?.debugDescription ?? "", privacy: .private(mask: .hash))
        """)
    }

    @MainActor
    func storage<S: AnyObject>(_ storage: S, invalidates keys: Set<StorageKey>) {
        // logger is a Logger class object
        logger.trace("""
        [Storage] \(ObjectIdentifier(storage).debugDescription):
        \n\t invalidates keys: \(keys.debugDescription)
        """)
    }
}
