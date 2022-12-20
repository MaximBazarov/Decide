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

import OSLog

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
    var observations: ObservationSystem

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
         file: String = #file,
         fileID: String = #fileID,
         line: Int = #line,
         column: Int = #column,
         function: String = #function
    ) {
        let context: Context = Context(
            className: function,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
        self.storage = storage
        self.dependencies = dependencies
        self.observations = observations
        let post = Signposter()
        let o = ObjectIdentifier(storage as AnyObject)
        post.logger.trace("[Reader] initialized with \(o.debugDescription) context: \(context.debugDescription)")
    }

    func read<T>(
        key: StorageKey,
        fallbackValue: ValueProvider<T>,
        shouldStoreDefaultValue: Bool,
        context: Context
    ) -> T {
        let post = Signposter()
        let end = post.readStart(key: key, owner: ownerKey)
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
            post.logger.trace("[Storage] returns \(String(reflecting: value), privacy: .private(mask: .hash)) for key: \(key.debugDescription)")
            return value
        } catch {
            let post = Signposter()
            let end = post.fallbackWriteStart(key: key, owner: ownerKey)
            defer {
                end()
            }
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

//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//

let readWriteOperations: StaticString = "Storage Reader/Writer"

private extension Signposter {

    nonisolated func readStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let state = signposter.beginInterval(
            readWriteOperations,
            id: id,
            "read: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(readWriteOperations, state)
        }
    }

    nonisolated func fallbackWriteStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let state = signposter.beginInterval(
            readWriteOperations,
            id: id,
            "fallback: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(readWriteOperations, state)
        }
    }
}
