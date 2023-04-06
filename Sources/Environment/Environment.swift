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


/// A protocol defining an environment for executing ``Decision`` and ``Effect``
/// instances within a ``Storage``.
@MainActor public final class Environment {

    /// The execution Context in which the `Environment` was instantiated.
    public let context: Context

    let storage: Storage
    let observation: ObservationSystem

    /// Creates a new instance of the `Environment`.
    ///
    /// Automatically gathers the Context from where it was executed.
    ///
    /// - Parameters:
    /// - storage: An optional custom Storage instance.
    /// If not provided, a default implementation will be used.
    public init(
        storage: Storage? = nil,
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
    }

    /// Executes the given `Decision` then the `Effect` returned recursively until `NoOperation` is returned.
    /// - Parameters:
    ///     - decision: The `Decision` to execute.
    ///     - context: context where
    public func execute(_ decision: Decision, context: Context) {
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

    /// Performs the effect and then executes the decision
    nonisolated private func perform(_ effect: Effect, context: Context) {
        Task.detached {
            let decision = await effect.perform()
            await self.execute(decision, context: context)
        }
    }
}
