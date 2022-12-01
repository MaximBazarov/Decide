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
import OSLog


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

    var observationSystem: ObservationSystem { get }
}


//===----------------------------------------------------------------------===//
// MARK: - Decision Core (Default)
//===----------------------------------------------------------------------===//


// MARK: Public
public extension DecisionCore {
    @MainActor func execute(_ decision: Decision) {
        if isNoop(decision) { return }
        let poster = Signposter()
        let effect = poster.decisionStart(decision) {
            var updatedKeys: Set<StorageKey> = []
            _reader.onWrite = { updatedKeys.insert($0) }
            _writer.onWrite = { updatedKeys.insert($0) }

            //=== State Update
            let effect = decision.execute(read: _reader, write: _writer)

            //=== Traverse Dependency Graph
            let updated = updatedKeys
                .flatMap { _dependencies.popDependencies(of: $0) }

            //=== Notify Observers
            _observation.didChangeValue(for: Set<StorageKey>(updated))
            return effect
        }
        // Execute effect if there's any
        if isNoop(effect) { return }
        let effectEnd = poster.effectStart(effect)
        Task.detached(priority: .background) { [execute, _reader] in

            let decision = await effect.perform(read: _reader)
            Task.detached(priority: .high) { @MainActor in
                effectEnd()
                execute(decision)
            }
        }
    }

    func writer() -> StorageWriter { _writer }
    func reader() -> StorageReader { _reader }

    var observationSystem: ObservationSystem {
        _observation
    }
}

// MARK: Props/Init
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
        _reader = StorageReader(storage: storage, dependencies: dependencies, observations: observation)
        _writer = StorageWriter(storage: storage, dependencies: dependencies, observations: observation)
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//

extension Signposter {
    nonisolated func decisionStart(_ decision: Decision, _ job: () -> Effect) -> Effect {
        let name: StaticString = "Decision"
        let state = signposter.beginInterval(
            name,
            id: id,
            "decision: \(decision.debugDescription, privacy: .private(mask: .hash))"
        )
        defer {
            signposter.endInterval(name, state)
        }
        return job()
    }

    nonisolated func effectStart(_ effect: Effect) -> () -> Void {
        let name: StaticString = "Effect"
        let state = signposter.beginInterval(
            name,
            id: id,
            "effect: \(effect.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }
}
