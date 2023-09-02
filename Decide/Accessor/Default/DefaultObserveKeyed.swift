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

/// 
@propertyWrapper
@MainActor public struct DefaultObserveKeyed<
    Identifier: Hashable,
    State: KeyedState<Identifier>,
    Value
> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<State, Property<Value>>
    private var valueObserve: KeyedValueObserve<Identifier, State, Value>?

    public init(
        _ keyPath: KeyPath<State, Property<Value>>
    ) {
        propertyKeyPath = keyPath
    }

    public init<WrappedProperty: PropertyModifier>(
        _ keyPath: KeyPath<State, WrappedProperty>
    ) where WrappedProperty.Value == Value {
        propertyKeyPath = keyPath.appending(path: \.wrappedValue)
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, KeyedValueObserve<Identifier, State, Value>>,
        storage storageKeyPath: WritableKeyPath<EnclosingObject, Self>
    ) -> KeyedValueObserve<Identifier, State, Value> {
        get {
            var storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            let environment = instance.environment
            storage.environment = environment
            let observer = Observer(instance)
            if storage.valueObserve == nil {
                storage.valueObserve = KeyedValueObserve<Identifier, State, Value>(
                    bind: propertyKeyPath,
                    observer: observer,
                    environment: environment
                )
            }
            return storage.valueObserve!
        }
        set {}
    }
    
    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: KeyedValueObserve<Identifier, State, Value> {
        get { fatalError() }
        set { fatalError() }
    }
}

@MainActor public struct KeyedValueObserve<Identifier: Hashable, State: KeyedState<Identifier>, Value> {
    unowned var environment: ApplicationEnvironment

    let observer: Observer
    let propertyKeyPath: KeyPath<State, Property<Value>>

    init(
        bind propertyKeyPath: KeyPath<State, Property<Value>>,
        observer: Observer,
        environment: ApplicationEnvironment
    ) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
        self.environment = environment
    }

    public subscript(_ identifier: Identifier) -> Value {
        get {
            environment.subscribe(observer, on: propertyKeyPath, at: identifier)
            return environment.getValue(propertyKeyPath, at: identifier)
        }
    }
}
