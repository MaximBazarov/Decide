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
// MARK: - Public Interface
//===----------------------------------------------------------------------===//

/// Returns a decision, that does nothing and produces no effect, so execution loop will be completed.
public let noDecision: Decision = NoOperation.shared

/// Returns an effect, that does nothing and produces no decision, so execution loop will be completed.
public let noEffect: Effect = NoOperation.shared



//===----------------------------------------------------------------------===//
// MARK: - No Operation Internal Implementation
//===----------------------------------------------------------------------===//

@MainActor final class NoOperation: Effect, Decision {

    func perform() async -> Decision {
        Self.shared
    }

    func execute(read: StorageReader, write: StorageWriter) -> Effect {
        Self.shared
    }

    nonisolated init() {}
    nonisolated static let shared = NoOperation()
}

func isNoop(_ object: Any) -> Bool {
    ObjectIdentifier(object as AnyObject) == ObjectIdentifier(NoOperation.shared)
}
