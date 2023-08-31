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
    func mutate(environment: DecisionEnvironment)
}

/// A restricted interface of ``ApplicationEnvironment`` provided to ``Decision``.
@MainActor public final class DecisionEnvironment {

    unowned var environment: ApplicationEnvironment

    var transactions: Set<Transaction> = []
    var effects: [Effect] = []

    init(_ environment: ApplicationEnvironment) {
        self.environment = environment
    }

    public subscript<State: AtomicState, Value>(
        _ propertyKeyPath: KeyPath<State, Property<Value>>
    ) -> Value {
        get {
            environment.getValue(propertyKeyPath)
        }
        set {
            setValue(propertyKeyPath, newValue)
        }
    }

    public subscript<ID:Hashable, State: KeyedState<ID>, Value>(
        _ propertyKeyPath: KeyPath<State, Property<Value>>,
        at identifier: ID
    ) -> Value {
        get {
            environment.getValue(propertyKeyPath, at: identifier)
        }
        set {
            setValue(propertyKeyPath, newValue, at: identifier)
        }
    }

    func setValue<State: AtomicState, Value>(
        _ keyPath: KeyPath<State, Property<Value>>,
        _ newValue: Value
    ) {
        transactions.insert(
            Transaction(keyPath, newValue: newValue)
        )
    }

    /// Set value at ``Property`` KeyPath on ``KeyedState``.
    func setValue<ID:Hashable, State: KeyedState<ID>, Value>(
        _ keyPath: KeyPath<State, Property<Value>>,
        _ newValue: Value,
        at identifier: ID
    ) {
        transactions.insert(
            Transaction(keyPath, newValue: newValue, at: identifier)
        )
    }

    public func perform<E: Effect>(effect: E) {
        effects.append(effect)
    }
}

