//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
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

/// Provides a default value of type `T`
public typealias ValueProvider<T> = @MainActor () -> T

//===----------------------------------------------------------------------===//
// MARK: - Storage Key
//===----------------------------------------------------------------------===//

/// A unique (during session) identifier of the value in the ``StorageSystem``.
/// The identifier will not necessarily be the same among app instances/sessions.
public final class StorageKey: Hashable, CustomDebugStringConvertible {
    let typeKey: AnyHashable
    let additionalKeys: [AnyHashable]

    private let _typeName: String

    init<T>(type: T.Type, additionalKeys: [AnyHashable]) {
        self.typeKey = ObjectIdentifier(type.self)
        self._typeName = String(reflecting: type)
        self.additionalKeys = additionalKeys
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Storage I/O
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
    var observations: ObservationSystem
    let _telemetry: Telemetry
    let context: Context

    /// Report back written keys (default values)
    var onWrite: (StorageKey) -> Void = {_ in }

    var ownerKey: StorageKey? = nil


    func withOwner(_ owner: StorageKey) -> StorageReader {
        self.ownerKey = owner
        return self
    }

    init(storage: StorageSystem,
         dependencies: DependencySystem,
         observations: ObservationSystem,
         context: Context
    ) {
        self.storage = storage
        self.dependencies = dependencies
        self.observations = observations
    }

    func read<T>(
        key: StorageKey,
        fallbackValue: ValueProvider<T>,
        shouldStoreDefaultValue: Bool,
        context: Context
    ) -> T {

        let end = _telemetry.readStart(key: key, owner: ownerKey)
        defer { end() }
        do {
            if let owner = ownerKey, key != owner {
                dependencies.add(dependency: key, thatInvalidates: owner)
            }

            let value: T = try storage.getValue(
                for: key,
                onBehalf: ownerKey,
                context: context
            )
            //            post.logger.trace("""
            //                \(key.debugDescription, privacy: .private(mask: .hash)):
            //                \(String(reflecting: value), privacy: .private(mask: .hash))
            //            """)
            return value
        } catch {
            let end = _telemetry.fallbackWriteStart(key: key, owner: ownerKey)
            defer { end() }
            let newValue = fallbackValue()
            if shouldStoreDefaultValue {
                onWrite(key)
                storage.invalidate(keys: dependencies.popDependencies(of: key), changed: key)
                storage.setValue(newValue, for: key, onBehalf: key, context: context)
            }
            return newValue
        }
    }
}


/// Writes the value into the storage for a provided key.
/// ```swift
/// // write: StorageWriter
/// write(x, into: SomeState.self)
/// ```
@MainActor public final class StorageWriter {
    var storage: StorageSystem
    var dependencies: DependencySystem
    var observations: ObservationSystem
    let context: Context
    let _telemetry: Telemetry

    var onWrite: (StorageKey) -> Void = {_ in }

    init(
        storage: StorageSystem,
        dependencies: DependencySystem,
        observations: ObservationSystem,
        telemetry: Telemetry,
        context: Context
    ) {
        self.storage = storage
        self.dependencies = dependencies
        self.observations = observations
        self._telemetry = telemetry
        self.context = context
    }

    func write<T>(_ value: T, for key: StorageKey, onBehalf owner: StorageKey?, context: Context) {
        let end = _telemetry.writeStart(key: key, owner: owner, context: context)
        defer {
            onWrite(key)
            end()
        }
        let keyDependencies = dependencies.popDependencies(of: key)
        storage.invalidate(keys: keyDependencies, changed: key)
        storage.setValue(value, for: key, onBehalf: owner, context: context)
#warning("TODO: Check if onWrite is enough and observations.didChangeValue(for: key) is not needed")
        observations.didChangeValue(for: key)
    }
}






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
// MARK: Hashable (Equitable)
//===----------------------------------------------------------------------===//

public extension StorageKey {
    func hash(into hasher: inout Hasher) {
        hasher.combine(typeKey)
        additionalKeys.forEach { hasher.combine($0) }
    }
}

public extension StorageKey {
    static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
        guard lhs.additionalKeys.count == rhs.additionalKeys.count
        else { return false }

        var result = lhs.typeKey == rhs.typeKey
        for index in lhs.additionalKeys.indices {
            result = result
            && lhs.additionalKeys[index] == rhs.additionalKeys[index]
        }
        return result
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Debug
//===----------------------------------------------------------------------===//

extension StorageKey {
    public var debugDescription: String {
        return Self.pretty(_typeName) + "  \(self.additionalKeys.map{ $0.debugDescription }.joined(separator: ", "))"
    }

    static func pretty(_ value: String) -> String {
        let str = value
            .replacingOccurrences(of: "ObjectIdentifier", with: "")
            .replacingOccurrences(of: "AnyHashable", with: "")
            .replacingOccurrences(of: "((", with: "(")
            .replacingOccurrences(of: "))", with: ")")
            .split(separator: ".")
            .suffix(1)
            .joined(separator: ".")


        return String(str)
    }
}
