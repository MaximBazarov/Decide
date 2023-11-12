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

    public subscript<Storage: AtomicStorage, Value>(_ keyPath: KeyPath<Storage, ObservableState<Value>>) -> Value {
        get { environment.observableState(keyPath).wrappedValue }
    }

    public subscript<Identifier, Storage, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        at identifier: Identifier
    ) -> Value
    where Identifier: Hashable, Storage: KeyedStorage<Identifier>
    {
        get { environment.observableState(keyPath, at: identifier).wrappedValue }
    }

    public subscript<Storage: AtomicStorage, Value>(_ keyPath: KeyPath<Storage, Mutable<Value>>) -> Value {
        get {
            self[keyPath.appending(path: \.wrappedValue)]
        }
    }

    public subscript<Identifier, Storage, Value>(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        at identifier: Identifier
    ) -> Value
    where Identifier: Hashable, Storage: KeyedStorage<Identifier>
    {
        get {
            self[keyPath.appending(path: \.wrappedValue), at: identifier]
        }
    }

    /// Makes a decision and awaits for all the effects.
    public func make(
        decision: Decision,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        await environment.makeAwaiting(decision: decision, context: Context(file: file, line: line))
    }

    @MainActor public func instance<Storage: AtomicStorage, Object>(_ keyPath: KeyPath<Storage, DefaultInstance<Object>>) -> Object {
        let object = environment.defaultInstance(at: keyPath).wrappedValue
        return object
    }

    @MainActor public func instance<Storage: AtomicStorage, Object: EnvironmentManagedObject>(_ keyPath: KeyPath<Storage, DefaultInstance<Object>>) -> Object {
        let object = environment.defaultInstance(at: keyPath).wrappedValue
        object.environment = self.environment
        return object
    }
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
