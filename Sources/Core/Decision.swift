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

import Foundation
//===----------------------------------------------------------------------===//
// MARK: - Decision
//===----------------------------------------------------------------------===//


@MainActor public protocol Decision: CustomDebugStringConvertible {
    /// Describes how decision has to be executed.
    /// Applying state changes using read/write.
    /// All heavy or asynchronous work **must** be isolated in produced ``Effect``.
    ///
    /// - Parameters:
    ///   - read: Connected to the ``StorageSystem`` and configured ``StorageReader``.
    ///   - write: Connected to the ``StorageSystem`` and configured ``StorageWriter``.
    /// - Returns: Effect with enclosed heavy/async job.
    func execute(read: StorageReader, write: StorageWriter) -> Effect
}

extension Decision {

    nonisolated public var debugDescription: String {
        return String(reflecting: Self.self)
            .split(separator: ".")
            .map{ String($0) }
            .last ?? "<UNTITLED>"
    }
}

public struct DecisionEffect: Effect {
    let decision: Decision

    public func perform(read: StorageReader) async -> Decision {
        decision
    }
}

public extension Decision {
    var asEffect: Effect {
        DecisionEffect(decision: self)
    }
}
