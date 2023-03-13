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

import SwiftUI
import OSLog

//===----------------------------------------------------------------------===//
// MARK: - SwiftUI Environment
//===----------------------------------------------------------------------===//
struct CoreEnvironmentKey: EnvironmentKey {
    @MainActor
    static var defaultValue: DecisionExecutor = DecisionCore()
}

public extension EnvironmentValues {
    var decisionCore: DecisionExecutor {
        get { self[CoreEnvironmentKey.self] }
        set { self[CoreEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func decisionCore(_ core: DecisionExecutor) -> some View {
        environment(\.decisionCore, core)
    }
}

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

    func writer() -> StorageWriter { _writer }
    func reader() -> StorageReader { _reader }

    var observationSystem: ObservationSystem {
        _observation
    }

    internal var dependencySystem: DependencySystem {
        _dependencies
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
         observation: ObservationSystem? = nil,
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
        let post = Signposter()
        post.logger.trace("Core initialized, context: \(context.debugDescription)")
        let storage = storage ?? InMemoryStorage()
        let dependencies = dependencies ?? DependencyGraph()
        let observation = observation ?? ObservationSystem()
        _storage = storage
        _dependencies = dependencies
        _observation = observation
        _reader = StorageReader(storage: storage, dependencies: dependencies, observations: observation)
        _writer = StorageWriter(storage: storage, dependencies: dependencies, observations: observation)
    }

    public func execute(_ decision: Decision) {
        if isNoop(decision) { return }

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

        // Execute effect if there's any
        if isNoop(effect) { return }
        Task.detached {
            await self.perform(effect)
        }
    }


    /// Performs the effect and then executes the decision
    nonisolated private func perform(_ effect: Effect) async {
        let decision = await effect.perform(read: self.reader())
        await self.execute(decision)
    }
}



