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
    // MARK: - AtomicState/Property
    //===------------------------------------------------------------------===//

    /// Subscribe ``ObservableValue`` at ``Property`` KeyPath on ``AtomicState``.
    func subscribe<S: AtomicState, Value>(
        _ observableValue: ObservableValue,
        on keyPath: KeyPath<S, Property<Value>>
    ) {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath].projectedValue.valueContainer.observerStorage.subscribe(observableValue)
    }

    /// Subscribe ``EnvironmentObservingObject`` at ``Property`` KeyPath on ``AtomicState``.
    func subscribe<S: AtomicState, Value>(
        _ object: EnvironmentObservingObject,
        on keyPath: KeyPath<S, Property<Value>>
    ) {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath].projectedValue.valueContainer.observerStorage.subscribe(object)
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

    //===------------------------------------------------------------------===//
    // MARK: - AtomicState/PropertyModifier
    //===------------------------------------------------------------------===//

    /// Subscribe ``ObservableValue`` at ``PropertyModifier`` KeyPath on ``AtomicState``.
    func subscribe<S: AtomicState, P: PropertyModifier, Value>(
        _ observableValue: ObservableValue,
        on keyPath: KeyPath<S, P>
    ) where P.Value == Value {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath.appending(path: \.wrappedValue)]
            .projectedValue
            .valueContainer
            .observerStorage
            .subscribe(observableValue)
    }

    /// Subscribe ``EnvironmentObservingObject`` at ``PropertyModifier`` KeyPath on ``AtomicState``.
    func subscribe<S: AtomicState, P: PropertyModifier, Value>(
        _ object: EnvironmentObservingObject,
        on keyPath: KeyPath<S, P>
    ) where P.Value == Value {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath.appending(path: \.wrappedValue)]
            .projectedValue
            .valueContainer
            .observerStorage
            .subscribe(object)
    }

    /// Get value at ``PropertyModifier`` KeyPath on ``AtomicState``.
    func getValue<S: AtomicState, Value, P: PropertyModifier>(_ keyPath: KeyPath<S, P>) -> Value where P.Value == Value {
        let storage: S = self[S.key()]
        return storage[keyPath: keyPath.appending(path: \.wrappedValue)].wrappedValue
    }

    /// Set value at ``PropertyModifier`` KeyPath on ``AtomicState``.
    func setValue<S: AtomicState, Value, P: PropertyModifier>(_ newValue: Value, _ keyPath: KeyPath<S, P>) where P.Value == Value {
        let storage: S = self[S.key()]
        storage[keyPath: keyPath.appending(path: \.wrappedValue)].wrappedValue = newValue
    }
}
