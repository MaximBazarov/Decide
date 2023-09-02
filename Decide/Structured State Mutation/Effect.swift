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
@MainActor public final class EffectEnvironment {
    unowned var environment: ApplicationEnvironment

    init(_ environment: ApplicationEnvironment) {
        self.environment = environment
    }

    public subscript<State: AtomicState, Value>(_ propertyKeyPath: KeyPath<State, Property<Value>>) -> Value {
        get { environment.getValue(propertyKeyPath) }
    }

    public subscript<Identifier, State, Value>(
        _ propertyKeyPath: KeyPath<State, Property<Value>>,
        at identifier: Identifier
    ) -> Value
    where Identifier: Hashable, State: KeyedState<Identifier>
    {
        get { environment.getValue(propertyKeyPath, at: identifier) }
    }

    public subscript<State: AtomicState, Value>(_ propertyKeyPath: KeyPath<State, Mutable<Value>>) -> Value {
        get {
            environment.getValue(propertyKeyPath.appending(path: \.wrappedValue))
        }
    }

    public subscript<Identifier, State, Value>(
        _ propertyKeyPath: KeyPath<State, Mutable<Value>>,
        at identifier: Identifier
    ) -> Value
    where Identifier: Hashable, State: KeyedState<Identifier>
    {
        get {
            environment.getValue(propertyKeyPath.appending(path: \.wrappedValue), at: identifier)
        }
    }

    /// Makes a decision and awaits for all the effects.
    public func make(decision: Decision) async {
        await environment.makeAwaiting(decision: decision)
    }

    @MainActor public func instance<State: AtomicState, Object>(_ keyPath: KeyPath<State, DefaultInstance<Object>>) -> Object {
        let object = environment.defaultInstance(at: keyPath).wrappedValue
        return object
    }

    @MainActor public func instance<State: AtomicState, Object: EnvironmentManagedObject>(_ keyPath: KeyPath<State, DefaultInstance<Object>>) -> Object {
        let object = environment.defaultInstance(at: keyPath).wrappedValue
        object.environment = self.environment
        return object
    }
}
