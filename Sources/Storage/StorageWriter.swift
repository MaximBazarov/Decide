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
        let post = Signposter()
        let end = post.writeStart(key: key, owner: owner)
        defer { end() }
        onWrite(key)
        storage.setValue(value, for: key, onBehalf: owner)
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//

private extension Signposter {

    nonisolated func writeStart(key: StorageKey, owner: StorageKey?) -> () -> Void {
        let name: StaticString = "Storage Writer: write"
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
