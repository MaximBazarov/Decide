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

//===----------------------------------------------------------------------===//
// MARK: - Storage Interface
//===----------------------------------------------------------------------===//

/// A protocol that combines StorageSystem, DependencySystem, and ObservationSystem to execute a Decision and its associated Effect, and then run the produced Decision and Effect recursively until either a ``NoOperation`` decision or a NoOperation effect is returned.
///
/// Implement `Storage` to define custom behavior for executing `Decision` instances and running their associated `Effect`s.
///
/// Example:
/// ```
/// class MyStorage: Storage {
///     func execute(_ decision: Decision, context: Context?) {
///         // Execute the given decision and its associated effects.
///         // ...
///
///         // Run the produced decision and its associated effects recursively.
///     }
///
///     func reader(context: Context?) -> StorageReader {
///         // Returns a `StorageReader` instance configured for the enclosed `StorageSystem`.
///     }
///
///     func writer(context: Context?) -> StorageWriter {
///         // Returns a `StorageWriter` instance configured for the enclosed `StorageSystem`.
///     }
///
///     var observationSystem: ObservationSystem {
///         // Returns the `ObservationSystem` used by the `Storage`.
///     }
/// }
/// ```
@MainActor public protocol Storage {
    /// Executes the given `Decision` and its associated `Effect`, and then runs the produced `Decision` and `Effect` recursively.
    /// - Parameters:
    ///     - decision: The `Decision` to execute.
    ///     - context: Optional context for the execution of the decision and its associated effects.
    func execute(_ decision: Decision, context: Context)

    /// Returns a `StorageReader` instance configured for the enclosed `StorageSystem`.
    /// - Parameter context: Optional context for the storage reader.
    /// - Returns: A `StorageReader` instance configured for the enclosed `StorageSystem`.
    func reader(context: Context) -> StorageReader

    /// Returns a `StorageWriter` instance configured for the enclosed `StorageSystem`.
    /// - Parameter context: Optional context for the storage writer.
    /// - Returns: A `StorageWriter` instance configured for the enclosed `StorageSystem`.
    func writer(context: Context) -> StorageWriter
}

//===----------------------------------------------------------------------===//
// MARK: - Decision-Effect Storage
//===----------------------------------------------------------------------===//

@MainActor public final class DecisionEffectStorage: Storage {

    public let context: Context

    private let _storage: StorageSystem
    private let _telemetry: Telemetry

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
        self.context = context
        let telemetry = Telemetry(
            subsystem: "decide",
            category: "core"
        )
        self._telemetry = telemetry
        let storage = storage ?? InMemoryStorage()
        let dependencies = dependencies ?? DependencyGraph()
        let observation = observation ?? ObservationSystem(telemetry: telemetry)
        _storage = storage
        _dependencies = dependencies
        _observation = observation
        _reader = StorageReader(storage: storage, dependencies: dependencies, observations: observation, context: context)
        _writer = StorageWriter(storage: storage, dependencies: dependencies, observations: observation, telemetry: _telemetry, context: context)
    }

    public func execute(_ decision: Decision, context: Context) {
        _telemetry.logger.trace("""
            (execute) Decision: \(decision.debugDescription), \(context.debugDescription)
        """)
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
            await self.perform(effect, context: context)
        }
    }

    public func writer(context: Context) -> StorageWriter { _writer }
    public func reader(context: Context) -> StorageReader { _reader }
    var observationSystem: ObservationSystem { _observation }

    var dependencySystem: DependencySystem { _dependencies }

    /// Performs the effect and then executes the decision
    nonisolated private func perform(_ effect: Effect, context: Context) async {
        let decision = await effect.perform(read: self.reader(context: context))
        await self.execute(decision, context: context)
    }
}



