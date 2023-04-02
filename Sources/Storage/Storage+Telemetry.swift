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

let readWriteOperations: StaticString = "Storage Reader/Writer"

private extension Telemetry {

    nonisolated func writeStart(key: StorageKey, owner: StorageKey?, context: Context) -> () -> Void {
        let state = signposter.beginInterval(
            readWriteOperations,
            id: id,
            "write: \(key.debugDescription, privacy: .private(mask: .hash)), owner: \(owner?.debugDescription ?? "—", privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(readWriteOperations, state)
        }
    }

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
