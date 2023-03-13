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
    public func getValue<T>(for key: StorageKey, onBehalf ownerKey: StorageKey?, context: Context) throws -> T {
        let post = Signposter()
        let end = post.readStart(key: key, owner: ownerKey)
        defer { end() }
        guard values.keys.contains(key) else { throw NoValueInStorage(key) }
        guard let value = values[key] as? T else { throw ValueTypeMismatch(key) }
        post.logger.trace("[Storage] \(ObjectIdentifier(self).debugDescription) returns: \(String(describing: value)) for key: \(key.debugDescription) owner: \(ownerKey.debugDescription, privacy: .private(mask: .hash))")
        return value
    }

    public func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?, context: Context) {
        let post = Signposter()
        let end = post.writeStart(key: key, owner: ownerKey, context: context)
        defer { end() }
        post.logger.trace("[Storage] \(ObjectIdentifier(self).debugDescription) set value: \(String(describing: value)) into key: \(key.debugDescription) \n\(context.debugDescription)")        
        values[key] = value
    }

    @MainActor func invalidate(keys: Set<StorageKey>, changed: StorageKey) {
        let post = Signposter()
        let end = post.invalidateDependenciesStart(keys: keys, key: changed)
        defer { end() }
        post.logger.trace("[Storage] \(ObjectIdentifier(self).debugDescription) invalidates: \(keys.debugDescription, privacy: .private(mask: .hash))")
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
let storageOperations: StaticString = "Storage"

private extension Signposter {
    nonisolated func invalidateDependenciesStart(keys: Set<StorageKey>, key: StorageKey) -> () -> Void {
        let state = signposter.beginInterval(
            dependencyOperations,
            id: id,
            "invalidate: \(key.debugDescription, privacy: .private(mask: .hash)), dependencies: \(keys.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(dependencyOperations, state)
        }
    }

    nonisolated func readStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let state = signposter.beginInterval(
            storageOperations,
            id: id,
            "read: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(storageOperations, state)
        }
    }

    nonisolated func writeStart(key: StorageKey, owner: StorageKey?, context: Context) -> () -> Void {
        let state = signposter.beginInterval(
            storageOperations,
            id: id,
            "write: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))\n\(context.debugDescription)"
        )
        return { [signposter] in
            signposter.endInterval(storageOperations, state)
        }
    }
}
