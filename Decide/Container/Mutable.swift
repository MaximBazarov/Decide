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



/// Marks property as mutable, to use in bindings
@propertyWrapper @MainActor public final class Mutable<Value>: PropertyModifier {
    /// Default Value
    private(set) public var wrappedValue: Property<Value>

    public var projectedValue: Mutable<Value> { self }

    public init(wrappedValue: Property<Value>) {
        self.wrappedValue = wrappedValue
    }
}


extension ApplicationEnvironment {
    func subscribe<S: AtomicState, Value>(
        _ observableValue: ObservableValue,
        on keyPath: KeyPath<S, Mutable<Value>>
    ) {
        self.subscribe(observableValue, on: keyPath.appending(path: \.wrappedValue))
    }

    func subscribe<S: AtomicState, Value>(
        _ object: EnvironmentObservingObject,
        on keyPath: KeyPath<S, Mutable<Value>>
    ) {
        self.subscribe(object, on: keyPath.appending(path: \.wrappedValue))
    }

    func getValue<S: AtomicState, Value>(_ keyPath: KeyPath<S, Mutable<Value>>) -> Value {
        self.getValue(keyPath.appending(path: \.wrappedValue))
    }

    func setValue<S: AtomicState, Value>(_ newValue: Value, _ keyPath: KeyPath<S, Mutable<Value>>) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue))
    }
    
    func getValue<I:Hashable, S: KeyedState<I>, Value>(
        _ keyPath: KeyPath<S, Mutable<Value>>,
        at identifier: I
    ) -> Value {
        let storage: S = self[S.key(identifier)]
        return storage[keyPath: keyPath].wrappedValue.wrappedValue
    }

    func setValue<I:Hashable, S: KeyedState<I>, Value>(
        _ newValue: Value,
        _ keyPath: KeyPath<S, Mutable<Value>>,
        at identifier: I
    ) {
        let storage: S = self[S.key(identifier)]
        storage[keyPath: keyPath].wrappedValue.wrappedValue = newValue
    }
}
