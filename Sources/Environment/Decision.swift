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


/// Encloses the synchronous state update
/// using ``StorageReader`` and ``StorageWriter`` configured with storage.
@MainActor public protocol Decision {

    /// Describes the execution process for a decision.
    /// State changes are applied using read and write operations.
    /// Any heavy or asynchronous work **must** be isolated in the produced ``Effect``.
    ///
    /// - Parameters:
    ///  - read: A ``StorageReader`` connected to the ``Storage`` and ``Context`` of the decision execution point for reading data.
    ///  - write: A ``StorageWriter`` connected to the ``Storage`` and ``Context`` of the decision execution point for writing data.
    /// - Returns: An ``Effect`` encapsulating any heavy or asynchronous tasks.
    func execute(read: StorageReader, write: StorageWriter) -> Effect
}

public extension Decision {

    /// Returns an ``Effect`` that returns the ``Decision`` immediately.
    ///
    /// > Note: Since this is an effect,
    /// the decision execution order is no longer guaranteed.
    var asEffect: Effect {
        DecisionEffect(decision: self)
    }
}

struct DecisionEffect: Effect {
    let decision: Decision

    public func perform() async -> Decision {
        decision
    }
}
