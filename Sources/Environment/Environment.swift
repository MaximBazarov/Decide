//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation


//===----------------------------------------------------------------------===//
// MARK: - Environment
//===----------------------------------------------------------------------===//

// TODO: This part needs better solution, less components if possible, better testability.

/// Executing ``Decision`` and ``Effect``.
@MainActor public protocol DecisionEffectLoop {

    /// Executes ``Decision`` and performs its ``Effect``
    func execute(
        _ decision: Decision,
        reader: StorageReader,
        writer: StorageWriter,
        context: Context
    )


    /// Performs ``Effect``
    func perform(
        _ effect: Effect,
        execute: @MainActor @escaping (Decision, Context) async -> Void,
        context: Context
    )
}

@MainActor final class DefaultDecisionEffectLoop: DecisionEffectLoop {

    func execute(
        _ decision: Decision,
        reader: StorageReader,
        writer: StorageWriter,
        context: Context
    ) {
        guard !decision.isNoOp else { return }

        let effect = decision.execute(
            read: reader,
            write: writer
        )

        guard !effect.isNoOp else { return }
        perform(
            effect,
            execute: { decision, context in
                await MainActor.run {
                    self.execute(
                        decision,
                        reader: reader,
                        writer: writer,
                        context: context
                    )
                }
            },
            context: context
        )
    }

    nonisolated func perform(
        _ effect: Effect,
        execute: @MainActor @escaping (Decision, Context) async -> Void,
        context: Context
    ) {
        Task.detached {
            let decision = await effect.perform()
            guard !decision.isNoOp else { return }
            await execute(decision, context)
        }
    }
}

/// A protocol defining an environment for executing ``Decision`` and ``Effect``
/// instances within a ``Storage``.
@MainActor public final class Environment {

    /// The execution Context in which the `Environment` was instantiated.
    public let context: Context

    let storage: Storage
    let observation: ObservationSystem
    let decisionEffectLoop: DecisionEffectLoop

    /// Creates a new instance of the `Environment`.
    ///
    /// Automatically gathers the Context from where it was executed.
    ///
    /// - Parameters:
    /// - storage: An optional custom Storage instance.
    /// If not provided, a default implementation will be used.
    public init(
        storage: Storage? = nil,
        decisionEffectLoop: DecisionEffectLoop? = nil,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        let context: Context = Context(
            symbol: Self.self,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
        self.context = context
        self.storage = storage ?? KeyValueStorage()
        self.observation = ObservationSystem()
        self.decisionEffectLoop = decisionEffectLoop ?? DefaultDecisionEffectLoop()
    }

    /// Executes the given `Decision` then the `Effect` returned recursively until `NoOperation` is returned.
    /// - Parameters:
    ///     - decision: The `Decision` to execute.
    ///     - context: context where
    public func execute(_ decision: Decision, context: Context) {
        decisionEffectLoop.execute(
            decision,
            reader: reader(context: context),
            writer: writer(context: context),
            context: context
        )
    }

    /// Subscribes ``ObservableValue`` to specified key.
    public func subscribe(_ observableValue: ObservableValue, to key: StorageKey) {
    }

    /// Returns a ``StorageWriter`` instance configured with the `Storage`.
    public func writer(context: Context) -> StorageWriter {
        StorageWriter(storage: storage, context: context)
    }

    /// Returns a ``StorageReader`` instance configured with the `Storage`.
    public func reader(context: Context) -> StorageReader {
        StorageReader(storage: storage, context: context)
    }
}
