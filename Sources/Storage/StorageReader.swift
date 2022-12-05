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
    var onWrite: (StorageKey) -> Void = {_ in }
    var ownerKey: StorageKey? = nil


    func withOwner(_ owner: StorageKey) -> StorageReader {
        let reader = StorageReader(
            storage: storage,
            dependencies: dependencies,
            observations: observations
        )
        reader.ownerKey = owner
        return reader
    }

    init(storage: StorageSystem,
         dependencies: DependencySystem,
         observations: ObservationSystem
    ) {
        self.storage = storage
        self.dependencies = dependencies
        self.observations = observations
    }

    func read<T>(
        key: StorageKey,
        fallbackValue: ValueProvider<T>,
        shouldStoreDefaultValue: Bool
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
                onBehalf: ownerKey
            )

            return value
        } catch {
            let post = Signposter()
            let end = post.fallbackWriteStart(key: key, owner: ownerKey)
            defer { end() }
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
// MARK: - Logging
//===----------------------------------------------------------------------===//

private extension Signposter {

    nonisolated func readStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let name: StaticString = "Storage Reader: read"
        let state = signposter.beginInterval(
            name,
            id: id,
            "key: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }

    nonisolated func fallbackWriteStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let name: StaticString = "Storage Reader: fallback"
        let state = signposter.beginInterval(
            name,
            id: id,
            "key: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }
}
