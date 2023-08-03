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
    //===------------------------------------------------------------------===//
    // MARK: - Observability
    //===------------------------------------------------------------------===//
   
    func notifyObservers<I: Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Property<Value>>,
        _ identifier: I
    ) {
        let observers = popObservers(keyPath, identifier)
        observers.forEach { $0.notify() }
    }

    func popObservers<I: Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Property<Value>>,
        _ identifier: I
    ) -> Set<Observer> {
        let storage: S = self[S.key(identifier)]
        return storage[keyPath: keyPath].valueContainer.observerStorage.popObservers()
    }

    //===------------------------------------------------------------------===//
    // MARK: - AtomicState/Property
    //===------------------------------------------------------------------===//

    /// Subscribe ``ObservableValue`` at ``Property`` KeyPath on ``KeyedState``.
    func subscribe<I:Hashable, S: KeyedState<I>, Value>(
        _ observer: Observer,
        on keyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].projectedValue.valueContainer.observerStorage.subscribe(observer)
    }

    /// Get value at ``Property`` KeyPath on ``KeyedState``.
    func getValue<I:Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) -> Value {
        let storage: S = self[S.key(identifier)]
        return storage[keyPath: keyPath].wrappedValue
    }

    /// Set value at ``Property`` KeyPath on ``KeyedState``.
    func setValue<I:Hashable, S: KeyedState<I>, Value>(
        _ newValue: Value,
        _ keyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].wrappedValue = newValue
        notifyObservers(keyPath, identifier)
    }
}
