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

@propertyWrapper
@MainActor public final class Computed<Value> {

    var value: Value?
    var observerStorage = ObserverStorage()

    /// Default Value
    public var wrappedValue: (ComputationEnvironment) -> Value

    public var projectedValue: Computed<Value> {
        self
    }

    public init(
        wrappedValue: @escaping (ComputationEnvironment) -> Value,
        file: StaticString = #fileID, line: UInt = #line
    ) {
        self.wrappedValue = wrappedValue
        self.file = file.description
        self.line = line
    }

    // MARK: - Tracing
    let file: String
    let line: UInt
}

@propertyWrapper
@MainActor public final class ComputedKeyed<Identifier: Hashable, Value> {

    var value: Value?
    var observerStorage = ObserverStorage()

    /// Default Value
    public var wrappedValue: (ComputationEnvironment, Identifier) -> Value

    public var projectedValue: ComputedKeyed<Identifier, Value> {
        self
    }

    public init(
        wrappedValue: @escaping (ComputationEnvironment, Identifier) -> Value,
        file: StaticString = #fileID, line: UInt = #line
    ) {
        self.wrappedValue = wrappedValue
        self.file = file.description
        self.line = line
    }

    // MARK: - Tracing
    let file: String
    let line: UInt
}


extension ApplicationEnvironment {
    func getValue<
        State: AtomicState,
        Value
    >(
        _ keyPath: KeyPath<State, Computed<Value>>
    ) -> Value {
        let storage: State = self[State.key()]
        let computed = storage[keyPath: keyPath]
        let computeValue = computed.wrappedValue

        if let value = computed.value { return value }

        let newValue = computeValue(ComputationEnvironment(self))
        computed.value = newValue

        let observers = computed.observerStorage.popObservers()
        observers.forEach{ $0.notify() }

        return newValue
    }

    func getValue<
        Identifier: Hashable,
        State: KeyedState<Identifier>,
        Value
    >(
        _ keyPath: KeyPath<State, ComputedKeyed<Identifier, Value>>,
        at identifier: Identifier
    ) -> Value {
        let storage: State = self[State.key(identifier)]
        let computed = storage[keyPath: keyPath]
        let computeValue = computed.wrappedValue

        if let value = computed.value { return value }

        let newValue = computeValue(ComputationEnvironment(self), identifier)
        computed.value = newValue

        let observers = computed.observerStorage.popObservers()
        observers.forEach{ $0.notify() }

        return newValue
    }

}

@MainActor public final class ComputationEnvironment {

    unowned var environment: ApplicationEnvironment

    init(_ environment: ApplicationEnvironment) {
        self.environment = environment
    }

    public subscript<
        State: AtomicState,
        Value
    >(
        _ propertyKeyPath: KeyPath<State, Property<Value>>
    ) -> Value {
        get {
            environment.getValue(propertyKeyPath)
        }
    }

    public subscript<
        Modifier: PropertyModifier,
        State: AtomicState,
        Value
    >(
        _ propertyKeyPath: KeyPath<State, Modifier>
    ) -> Value where Modifier.Value == Value {
        get {
            environment.getValue(propertyKeyPath.appending(path: \.wrappedValue))
        }
    }

    public subscript<ID:Hashable, State: KeyedState<ID>, Value>(
        _ propertyKeyPath: KeyPath<State, Property<Value>>,
        at identifier: ID
    ) -> Value {
        get {
            environment.getValue(propertyKeyPath, at: identifier)
        }
    }
    
    public subscript<
        Modifier: PropertyModifier,
        ID:Hashable,
        State: KeyedState<ID>,
        Value
    >(
        _ propertyKeyPath: KeyPath<State, Modifier>,
        at identifier: ID
    ) -> Value where Modifier.Value == Value {
        get {
            environment.getValue(propertyKeyPath.appending(path: \.wrappedValue), at: identifier)
        }
    }
}
