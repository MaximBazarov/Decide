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

/// Encapsulates asynchronous execution of side-effects e.g. network call.
/// Provided with an ``EffectEnvironment`` to read state and make ``Decision``s.
public protocol Effect: Actor {
    func perform(in env: EffectEnvironment) async
}

/// A restricted interface of ``ApplicationEnvironment`` provided to ``Effect``.
public final class EffectEnvironment {
}

extension Effect {
    public var debugDescription: String {
        String(reflecting: self)
    }

    nonisolated var name: String {
        String(describing: type(of: self))
        + " (" + String(describing: self.self) + ")"
    }
}
