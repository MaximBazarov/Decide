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
import Combine

@MainActor final class ObserverStorage {
    var observers: Set<Observer> = []

    func subscribe(_ object: EnvironmentObservingObject) {
        guard let observer = try? Observer(WeakEnvironmentObservingObject(object))
        else { return }
        observers.insert(observer)
    }

    func subscribe(_ observableValue: ObservableValue) {
        observers.insert(Observer(observableValue))
    }

    func popObservers() -> Set<Observer> {
        let result = observers
        observers = []
        return result
    }
}

final class Observer: Hashable {
    private var notification: Notification
    private var id: ObjectIdentifier

    init(_ observer: ObservableValue) {
        self.notification = .observableValue(observer)
        self.id = ObjectIdentifier(observer)
    }

    struct ObjectDeallocated: Error {}
    init(_ observer: WeakEnvironmentObservingObject) throws {
        guard let object = observer.value else {
            throw ObjectDeallocated()
        }
        self.notification = .observingObject(observer)
        self.id = ObjectIdentifier(object)
    }

    enum Notification {
        case observableValue(ObservableValue)
        case observingObject(WeakEnvironmentObservingObject)
    }

    @MainActor func notify() {
        switch notification {
        case .observableValue(let observableValue):
            observableValue.objectWillChange.send()
        case .observingObject(let environmentObservingObject):
            environmentObservingObject.value?.environmentDidUpdate()
        }
    }

    public static func == (lhs: Observer, rhs: Observer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// ObservableObject for a value.
final class ObservableValue: ObservableObject {}

final class WeakEnvironmentObservingObject {
    weak var value: EnvironmentObservingObject?

    init(_ value: EnvironmentObservingObject) {
        self.value = value
    }
}

extension ApplicationEnvironment {

    func notifyObservers<S: AtomicState, Value>(
        _ keyPath: KeyPath<S, Property<Value>>
    ) {
        let observers = popObservers(keyPath)
        observers.forEach { $0.notify() }
    }

    func notifyObservers<S: AtomicState, P: PropertyModifier, Value>(
        _ keyPath: KeyPath<S, P>
    ) where P.Value == Value {
        let observers = popObservers(keyPath)
        observers.forEach { $0.notify() }
    }

    func notifyObservers<I: Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Property<Value>>,
        _ identifier: I
    ) {
        let observers = popObservers(keyPath, identifier)
        observers.forEach { $0.notify() }
    }

    func notifyObservers<I: Hashable, S: KeyedState<I>, P: PropertyModifier, Value>(
        _ keyPath: KeyPath<S, P>,
        _ identifier: I
    ) where P.Value == Value {
        let observers = popObservers(keyPath, identifier)
        observers.forEach { $0.notify() }
    }

    func popObservers<S: AtomicState, Value>(
        _ keyPath: KeyPath<S, Property<Value>>
    ) -> Set<Observer> {
        let storage: S = self[S.key()]
        return storage[keyPath: keyPath].valueContainer.observerStorage.popObservers()
    }

    func popObservers<S: AtomicState, P: PropertyModifier, Value>(
        _ keyPath: KeyPath<S, P>
    ) -> Set<Observer> where P.Value == Value {
        let storage: S = self[S.key()]
        return storage[keyPath: keyPath.appending(path: \.wrappedValue)]
            .valueContainer
            .observerStorage
            .popObservers()
    }

    func popObservers<I: Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Property<Value>>,
        _ identifier: I
    ) -> Set<Observer> {
        let storage: S = self[S.key(identifier)]
        return storage[keyPath: keyPath].valueContainer.observerStorage.popObservers()
    }

    func popObservers<I: Hashable, S: KeyedState<I>, P: PropertyModifier, Value>(
        _ keyPath: KeyPath<S, P>,
        _ identifier: I
    ) -> Set<Observer> where P.Value == Value {
        let storage: S = self[S.key(identifier)]
        return storage[keyPath: keyPath.appending(path: \.wrappedValue)]
            .valueContainer
            .observerStorage
            .popObservers()
    }
}
