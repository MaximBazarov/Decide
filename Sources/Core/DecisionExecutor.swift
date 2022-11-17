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
// MARK: - Decision Executor Protocol
//===----------------------------------------------------------------------===//

/// Core class that combines ``StorageSystem``, `DependencySystem` and `ObservationSystem` to execute ``Decision`` and produced by it ``Effect``
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
    @MainActor func execute(_ decision: Decision) {
        if isNoop(decision) { return }

        var updatedKeys: Set<StorageKey> = []
        _reader.onWrite = { updatedKeys.insert($0) }
        _writer.onWrite = { updatedKeys.insert($0) }

        print(" ┌─ [DECISION] \(decision.debugDescription) execution started ")
        let effect = decision.execute(read: _reader, write: _writer)
        let _effectSuffix = isNoop(effect) ? "No effect produced." : "effect -> \(effect.debugDescription)"


        // TODO: Performance Tests on a big graphs with a lot of connections
        print(" │  ├─ [DepS] get dependencies")
        let updated = updatedKeys
            .flatMap { _dependencies.popDependencies(of: $0) }
        print(" │  └─ \(updated.map{ $0.debugDescription })")

        print(" │  ├─ [ObS] notify ")
        _observation.didChangeValue(for: Set<StorageKey>(updated))
        print(" │  └─ \(updated.map{ $0.debugDescription })")
        print(" └─ execution finished. \(_effectSuffix)\n")
        // Execute effect if there's any
        if isNoop(effect) {
            return
        }

        Task(priority: .background) { [execute, _reader] in
            print("SIDE <───── effect \(effect.debugDescription). \n")
            let decision = await effect.perform(read: _reader)
            // log effect execution finished: effect
            print("SIDE ─────> effect \(effect.debugDescription). produces \(decision.debugDescription) \n")
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

    public convenience init(storage: StorageSystem? = nil) {
        self.init(storage: storage, dependencies: nil, observation: nil)
    }

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
