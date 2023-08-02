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

/// AtomicState is a managed by ``ApplicationEnvironment`` container for ``Property`` and ``DefaultInstance`` definitions,
/// its only requirement is to provide standalone `init()` so ``ApplicationEnvironment`` can instantiate it when necessary.
/// You should never use instances of ``AtomicState`` directly, use ``Property`` or ``DefaultInstance`` instead.
///
/// **Usage:**
/// ```swift
/// final class TestState: AtomicState {
///     // Declaration of a AtomicState property with a string value
///     // that is "default-value" by default.
///     @Property var name: String = "default-value"
///
///     // Declaration of the instance of a `NetworkingInterface` protocol
///     // that is `Networking()` by default.
///     @DefaultInstance var networking: NetworkingInterface = Networking()
/// }
/// ```
@MainActor open class AtomicState: ValueContainerStorage {
    required public init() {}

    static func key() -> ApplicationEnvironment.Key {
        .atomic(ObjectIdentifier(self))
    }
}

extension ApplicationEnvironment {
    //===------------------------------------------------------------------===//
    // MARK: - Observability
    //===------------------------------------------------------------------===//
    func notifyObservers<S: AtomicState, Value>(
        _ keyPath: KeyPath<S, Property<Value>>
    ) {
        let observers = popObservers(keyPath)
        observers.forEach { $0.notify() }
    }

    func popObservers<S: AtomicState, Value>(
        _ keyPath: KeyPath<S, Property<Value>>
    ) -> Set<Observer> {
        let storage: S = self[S.key()]
        return storage[keyPath: keyPath].valueContainer.observerStorage.popObservers()
    }


    //===------------------------------------------------------------------===//
    // MARK: - AtomicState/Property
    //===------------------------------------------------------------------===//

    /// Subscribe ``Observer`` at ``Property`` KeyPath on ``AtomicState``.
    func subscribe<S: AtomicState, Value>(
        _ observer: Observer,
        on keyPath: KeyPath<S, Property<Value>>
    ) {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath].projectedValue.valueContainer.observerStorage.subscribe(observer)
    }

    /// Get value at ``Property`` KeyPath on ``AtomicState``.
    func getValue<S: AtomicState, Value>(_ keyPath: KeyPath<S, Property<Value>>) -> Value {
        let storage: S = self[S.key()]
        return storage[keyPath: keyPath].wrappedValue
    }

    /// Set value at ``Property`` KeyPath on ``AtomicState``.
    func setValue<S: AtomicState, Value>(_ newValue: Value, _ keyPath: KeyPath<S, Property<Value>>) {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath].wrappedValue = newValue
        notifyObservers(keyPath)
    }
}
