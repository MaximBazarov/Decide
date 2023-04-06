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


/// Returns a decision, that does nothing and produces no effect,
/// so execution loop will be completed.
public let noDecision: Decision = NoOp.shared

/// Returns an effect, that does nothing and produces no decision,
/// so execution loop will be completed.
public let noEffect: Effect = NoOp.shared

@MainActor final class NoOp: Decision, Effect {

    func perform() async -> Decision {
        preconditionFailure("NoOp `perform` should never be called")
    }

    func execute(read: StorageReader, write: StorageWriter) -> Effect {
        preconditionFailure("NoOp `execute` should never be called")
    }

    static let shared = NoOp()
}

extension Decision {
    var isNoOp: Bool {
        ObjectIdentifier(self as AnyObject) == ObjectIdentifier(NoOp.shared)
    }
}

extension Effect {
    var isNoOp: Bool {
        ObjectIdentifier(self as AnyObject) == ObjectIdentifier(NoOp.shared)
    }
}
