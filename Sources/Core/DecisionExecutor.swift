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
import Combine


//===----------------------------------------------------------------------===//
// MARK: - Decision
//===----------------------------------------------------------------------===//

@MainActor public protocol Decision {
    func execute(read: StorageReader, write: StorageWriter) -> Effect
}


//===----------------------------------------------------------------------===//
// MARK: - Effect
//===----------------------------------------------------------------------===//

public protocol Effect {
    func perform() async -> Decision
}


//===----------------------------------------------------------------------===//
// MARK: - Decision Executor Protocol
//===----------------------------------------------------------------------===//

/// Core class that combines ``StorageSystem``, ``DependencySystem`` and ``ObservationSystem`` to execute ``Decision`` and produced by it ``Effect``
@MainActor public protocol DecisionExecutor {

    /// Executes the ``Decision`` and produced by it ``Effect``s.
    /// - Parameter decision: Decision to execute
    func execute(_ decision: Decision /*, context: Context*/)

    /// Returns a ``StorageReader`` configured for the enclosed ``StorageSystem``.
    func reader(/*context: Context*/) -> StorageReader

    /// Returns a ``StorageWriter`` configured for the enclosed ``StorageSystem``.
    func writer(/*context: Context*/) -> StorageWriter

    /// Adds provided publisher as to be notified when value at given ``StorageKey`` changes.
    func subscribe(publisher: ObservableObjectPublisher, for key: StorageKey)
}


//===----------------------------------------------------------------------===//
// MARK: - Decision Core (Default)
//===----------------------------------------------------------------------===//

// MARK: Public
public extension DecisionCore {
    func execute(_ decision: Decision) {
        var updatedKeys: Set<StorageKey> = []
        _reader.onWrite = { updatedKeys.insert($0) }
        _writer.onWrite = { updatedKeys.insert($0) }

        // log decision execution started:
        let effect = decision.execute(read: _reader, write: _writer)
        // log decision execution finished:

        // log dependencies calculation started: (Decision)
        let updated = updatedKeys
                .flatMap { _dependencies.popDependencies(of: $0) }
        // log dependencies calculation finished: (Decision) invalidated keys count (count)

        // log notification started: (Decision): (count) keys observers notified, payload, set of keys updated
        _observation.didChangeValue(for: Set<StorageKey>(updated))
        // log notification finished: (Decision)

        // log effect execution started: effect
        Task(priority: .background) { [execute] in
            let decision = await effect.perform()
            // log effect execution finished: effect
            execute(decision)
        }
    }

    func writer() -> StorageWriter { _writer }
    func reader() -> StorageReader { _reader }
    func subscribe(publisher: ObservableObjectPublisher, for key: StorageKey) {
        // log publisher subscribed to key started
        _observation.subscribe(publisher: publisher, for: key)
        // log publisher subscribed to key finished (publisher) observes (key)
    }
}

// MARK: Private
@MainActor public final class DecisionCore: DecisionExecutor {
    private let _storage: StorageSystem
    let _dependencies: DependencySystem
    let _observation: ObservationSystem
    let _reader: StorageReader
    let _writer: StorageWriter

    init(storage: StorageSystem? = nil,
         dependencies: DependencySystem? = nil,
         observation: ObservationSystem? = nil
    ) {
        let storage = storage ?? InMemoryStorage()
        let dependencies = dependencies ?? DependencyGraph()
        let observation = observation ?? ObservationSystem()
        _storage = storage
        _dependencies = dependencies
        _observation = observation
        _reader = StorageReader(storage: storage, dependencies: dependencies)
        _writer = StorageWriter(storage: storage, dependencies: dependencies)
    }
}
