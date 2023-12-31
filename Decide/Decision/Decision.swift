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

public typealias EnvironmentMutation = (DecisionEnvironment) -> Void

/// Encapsulates values updates applied to the ``ApplicationEnvironment`` immediately.
/// Provided with an ``DecisionEnvironment`` to read and write state.
/// Might return an array of ``Effect``, that will be performed asynchronously
/// within the ``ApplicationEnvironment``.
@MainActor public protocol Decision {
    func mutate(_ env: DecisionEnvironment) -> Void
}


/// Decision that has a `newValue` to use in `mutate`.
@MainActor public protocol ValueDecision: Decision {
    associatedtype Value
    var newValue: Value { get }
}

/// A restricted interface of ``ApplicationEnvironment`` provided to ``Decision``.
@MainActor public final class DecisionEnvironment {

    /**
     TODO: Implement isolation, creating a new instance of environment,
     that reads value form itself or uses a value from the original environment.

     Storing updated keys is a problem tho
     May be storing mutations isn't a bad idea

     But so tempting to remove the transaction part.
     */

    unowned var environment: SharedEnvironment

    var effects = [Effect]()

    init(_ environment: SharedEnvironment) {
        self.environment = environment
    }
}

extension Decision {
    var debugDescription: String {
        String(reflecting: self)
    }

    var name: String {
        String(describing: type(of: self))
    }
}
