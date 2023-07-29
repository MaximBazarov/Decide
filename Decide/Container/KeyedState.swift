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

/// KeyedState is a collection of ``AtomicState`` accessed by `Identifier`.
///
/// **Usage:**
/// ```swift
/// final class TestKeyedState: KeyedState<UUID> {
///     @Property var name: String = "default-value"
/// }
///
/// ```
/// to access the state `Identifier` will have to be provided together with ``Property`` KeyPath.
@MainActor open class KeyedState<Identifier: Hashable>: ValueContainerStorage {
    required public init() {}

    static func key(_ identifier: Identifier) -> ApplicationEnvironment.Key {
        .keyed(ObjectIdentifier(self), identifier)
    }
}

extension ApplicationEnvironment {
    func subscribe<I:Hashable, S: KeyedState<I>, Value>(
        _ object: EnvironmentObservingObject,
        on keyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].projectedValue.valueContainer.observerStorage.subscribe(object)
    }

    func subscribe<I:Hashable, S: KeyedState<I>, Value>(
        _ observableValue: ObservableValue,
        on keyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].projectedValue.valueContainer.observerStorage.subscribe(observableValue)
    }

    func subscribe<I:Hashable, S: KeyedState<I>, Value>(
        _ object: EnvironmentObservingObject,
        on keyPath: KeyPath<S, Mutable<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].wrappedValue.valueContainer.observerStorage.subscribe(object)
    }

    func subscribe<I:Hashable, S: KeyedState<I>, Value>(
        _ observableValue: ObservableValue,
        on keyPath: KeyPath<S, Mutable<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].wrappedValue.valueContainer.observerStorage.subscribe(observableValue)
    }

    func getValue<I:Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) -> Value {
        let storage: S = self[S.key(identifier)]
        return storage[keyPath: keyPath].wrappedValue
    }

}
