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

    /// A View modifier that provides a convenient way to set and access a ``DecisionExecutor`` instance in the environment.
    ///
    /// Use the `\.decisionCore` Key Path to access the ``DecisionExecutor`` instance in the environment.
    ///
    /// **Example:**
    /// ```
    /// struct ContentView: View {
    ///     @Environment(\.decisionCore) var decisionCore
    ///     ...
    /// }
    /// ```
    ///
    /// **Usage:**
    /// ```
    /// struct ContentView: View {
    ///     var body: some View {
    ///         MyView()
    ///             .decisionCore(injectedCore)
    ///     }
    /// }
    /// ```
    var decisionCore: DecisionExecutor {
        get { self[CoreEnvironmentKey.self] }
        set { self[CoreEnvironmentKey.self] = newValue }
    }
}

/// An extension that provides a convenient way to set a `DecisionExecutor` instance in the environment for a specific view.
///
/// Use the `decisionCore(_:)` modifier to set the `DecisionExecutor` instance in the environment for a specific view.
///
/// Example:
/// ```
/// struct MyView: View {
///     @MakeDecision var makeDecision: (Decision) -> Void
///
///     var body: some View {
///         Button("Accept") {
///             makeDecision(.accept)
///         }
///         Button("Reject") {
///             makeDecision(.reject)
///         }
///     }
/// }
///
/// MyView()
///     .decisionCore(MyCustomDecisionCore())
/// ```
public extension View {

    /// Sets the `DecisionExecutor` instance in the environment for this view.
    /// - Parameter core: The `DecisionExecutor` instance to set in the environment.
    /// - Returns: A new view that sets the `DecisionExecutor` instance in the environment.
    func decisionCore(_ core: DecisionExecutor) -> some View {
        environment(\.decisionCore, core)
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Decision Executor Protocol
//===----------------------------------------------------------------------===//

/// A protocol that combines StorageSystem, DependencySystem, and ObservationSystem to execute a Decision and its associated Effect, and then run the produced Decision and Effect recursively until either a ``NoOperation`` decision or a NoOperation effect is returned.
///
/// Implement `DecisionExecutor` to define custom behavior for executing `Decision` instances and running their associated `Effect`s.
///
/// Example:
/// ```
/// class MyDecisionExecutor: DecisionExecutor {
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
///         // Returns the `ObservationSystem` used by the `DecisionExecutor`.
///     }
/// }
/// ```
@MainActor public protocol DecisionExecutor {

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

    /// The `ObservationSystem` used by the `DecisionExecutor`.
    var observationSystem: ObservationSystem { get }
}


//===----------------------------------------------------------------------===//
// MARK: - Decision Core (Default)
//===----------------------------------------------------------------------===//


// MARK: Public
public extension DecisionCore {

    func writer(context: Context) -> StorageWriter { _writer }
    func reader(context: Context) -> StorageReader { _reader }

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

    public func execute(_ decision: Decision, context: Context) {
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

    /// Performs the effect and then executes the decision
    nonisolated private func perform(_ effect: Effect, context: Context) async {
        let decision = await effect.perform(read: self.reader(context: context))
        await self.execute(decision, context: context)
    }
}



