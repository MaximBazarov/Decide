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


/// Encapsulates value updates applied to the ``ApplicationEnvironment`` immediately.
/// Provided with an ``DecisionEnvironment`` to read and write state.
/// Might return an array of ``Effect``, that will be performed asynchronously
/// within the ``ApplicationEnvironment``.
@MainActor public protocol Decision {
    func mutate(environment: DecisionEnvironment) -> [Effect]
}

/// A restricted interface of ``ApplicationEnvironment`` provided to ``Decision``.
@MainActor public final class DecisionEnvironment {
    var transactions: Set<Transaction> = []
    var environment: ApplicationEnvironment

    init(_ environment: ApplicationEnvironment) {
        self.environment = environment
    }

    public subscript<S: AtomicState, V>(_ propertyKeyPath: KeyPath<S, Property<V>>) -> V {
        get {
            environment.getValue(propertyKeyPath)
        }
        set {
            setValue(propertyKeyPath, newValue: newValue)
        }
    }

    func setValue<S: AtomicState, V>(
        _ keyPath: KeyPath<S, Property<V>>,
        newValue: V
    ) {
        transactions.insert(
            Transaction(keyPath, newValue: newValue)
        )
    }
}

