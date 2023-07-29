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
    var environment: ApplicationEnvironment

    init(_ environment: ApplicationEnvironment) {
        self.environment = environment
    }

    public subscript<S: AtomicState, V>(_ propertyKeyPath: KeyPath<S, Property<V>>) -> V {
        get { environment.getValue(propertyKeyPath) }
    }

    public subscript<I, S, V>(
        _ propertyKeyPath: KeyPath<S, Property<V>>,
        at identifier: I
    ) -> V
    where I: Hashable, S: KeyedState<I>
    {
        get { environment.getValue(propertyKeyPath, at: identifier) }
    }

    public subscript<S: AtomicState, V>(_ propertyKeyPath: KeyPath<S, Mutable<V>>) -> V {
        get {
            environment.getValue(propertyKeyPath)
        }
    }

    public subscript<I, S, V>(
        _ propertyKeyPath: KeyPath<S, Mutable<V>>,
        at identifier: I
    ) -> V
    where I: Hashable, S: KeyedState<I>
    {
        get {
            environment.getValue(propertyKeyPath, at: identifier)
        }
    }

    /// Makes a decision and awaits for all the effects.
    public func make(decision: Decision) async {
        await environment.makeAwaiting(decision: decision)
    }

    @MainActor public func instance<S: AtomicState, O>(_ keyPath: KeyPath<S, DefaultInstance<O>>) -> O {
        let obj = environment.defaultInstance(at: keyPath).wrappedValue
        return obj
    }

    @MainActor public func instance<S: AtomicState, O: EnvironmentManagedObject>(_ keyPath: KeyPath<S, DefaultInstance<O>>) -> O {
        let obj = environment.defaultInstance(at: keyPath).wrappedValue
        obj.environment = self.environment
        return obj
    }
}
