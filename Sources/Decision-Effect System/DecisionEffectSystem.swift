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

import Inject
import Distributed

//===----------------------------------------------------------------------===//
// MARK: - Decision-Effect System
//===----------------------------------------------------------------------===//

/// The system that executes ``Decision`` to mutate the app state, and executes produced by them ``Effect``s.
public protocol DecisionEffectSystem {
    /// Executes the ``Decision`` then returned ``Effect`` in the detached `Task` then its returned ``Decision`` and so on until received a ``NoOperation`` as an input.
    @MainActor func execute<D: Decision>(decision: D)
}

//===----------------------------------------------------------------------===//
// MARK: - Local Decision-Effect System
//===----------------------------------------------------------------------===//

/// Default decision-effect system, effects and decisions are executed locally.
public final class LocalDecisionEffectSystem: DecisionEffectSystem {
    @Injected(\.decide.storage) var storage

    @MainActor public func execute<D: Decision>(decision: D) {
        guard !(decision is NoOperation) else { return }

        let reader = storage.instance.storageReader
        let writer = storage.instance.storageWriter

        let effect = decision.execute(read: reader, write: writer)

        reportUpdates(reader, writer)

        Task.detached(priority: .utility, operation: {
            let decision = await effect.perform()
            await self.execute(decision: decision)
        })
    }

    private func reportUpdates(_ reader: StorageReader, _ writer: StorageWriter) {
        var updatedKeys = Set(writer.popKeys())
        reader.writtenDefaultValues.forEach { key, value in
            storage.instance.setValue(value, for: key, onBehalf: nil)
            updatedKeys.insert(key)
        }
        storage.instance.didUpdateKeys(&updatedKeys)
    }
}
