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
@MainActor public struct DefaultBindKeyed<I: Hashable, S: KeyedState<I>, Value> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<S, Property<Value>>
    private var valueBinding: KeyedValueBinding<I, S, Value>?

    public init(
        _ keyPath: KeyPath<S, Mutable<Value>>
    ) {
        propertyKeyPath = keyPath.appending(path: \.wrappedValue)
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, KeyedValueBinding<I, S, Value>>,
        storage storageKeyPath: WritableKeyPath<EnclosingObject, Self>
    ) -> KeyedValueBinding<I, S, Value> {
        get {
            var storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            let environment = instance.environment
            storage.environment = environment
            let observer = Observer(instance)
            if storage.valueBinding == nil {
                storage.valueBinding = KeyedValueBinding(
                    bind: propertyKeyPath,
                    observer: observer,
                    environment: environment
                )
            }
            return storage.valueBinding!
        }
        set {}
    }
    
    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: KeyedValueBinding<I, S, Value> {
        get { fatalError() }
        set { fatalError() }
    }
}

@MainActor public struct KeyedValueBinding<I: Hashable, S: KeyedState<I>, Value> {
    unowned var environment: ApplicationEnvironment

    let observer: Observer
    let propertyKeyPath: KeyPath<S, Property<Value>>

    init(
        bind propertyKeyPath: KeyPath<S, Property<Value>>,
        observer: Observer,
        environment: ApplicationEnvironment
    ) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
        self.environment = environment
    }

    public subscript(_ identifier: I) -> Value {
        get {
            environment.subscribe(observer, on: propertyKeyPath, at: identifier)
            return environment.getValue(propertyKeyPath, at: identifier)
        }
        set {
            environment.setValue(newValue, propertyKeyPath, at: identifier)
        }
    }
}
