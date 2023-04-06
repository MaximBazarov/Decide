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


/// Encloses the asynchronous execution of side-effect.
public protocol Effect {

    /// Called by ``Environment`` on a shared thread pool.
    /// Produces the ``Decision`` that describes the necessary state updates.
    ///
    /// - Returns: A ``Decision`` that describes the required state updates.
    func perform() async -> Decision
}

public extension Effect {

    /// Returns a ``Decision`` that returns the ``Effect`` immediately.
    var asDecision: Decision {
        EffectDecision(effect: self)
    }
}

struct EffectDecision: Decision {
    let effect: Effect

    public func execute(read: StorageReader, write: StorageWriter) -> Effect {
        effect
    }
}
