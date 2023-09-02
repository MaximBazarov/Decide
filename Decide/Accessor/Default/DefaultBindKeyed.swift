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
@MainActor public struct DefaultBindKeyed<Identifier: Hashable, State: KeyedState<Identifier>, Value> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<State, Property<Value>>
    private var valueBinding: KeyedValueBinding<Identifier, State, Value>?
    let context: Context

    public init(
        _ keyPath: KeyPath<State, Mutable<Value>>,
        file: String = #fileID,
        line: Int = #line
    ) {
        let context = Context(file: file, line: line)
        self.context = context
        self.propertyKeyPath = keyPath.appending(path: \.wrappedValue)
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, KeyedValueBinding<Identifier, State, Value>>,
        storage storageKeyPath: WritableKeyPath<EnclosingObject, Self>
    ) -> KeyedValueBinding<Identifier, State, Value> {
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
                    environment: environment,
                    context: storage.context
                )
            }
            return storage.valueBinding!
        }
        set {}
    }
    
    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: KeyedValueBinding<Identifier, State, Value> {
        get { fatalError() }
        set { fatalError() }
    }
}

@MainActor public struct KeyedValueBinding<Identifier: Hashable, State: KeyedState<Identifier>, Value> {
    unowned var environment: ApplicationEnvironment

    let observer: Observer
    let propertyKeyPath: KeyPath<State, Property<Value>>
    let context: Context

    init(
        bind propertyKeyPath: KeyPath<State, Property<Value>>,
        observer: Observer,
        environment: ApplicationEnvironment,
        context: Context
    ) {
        self.context = context
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
        self.environment = environment
    }

    public subscript(_ identifier: Identifier) -> Value {
        get {
            environment.subscribe(observer, on: propertyKeyPath, at: identifier)
            return environment.getValue(propertyKeyPath, at: identifier)
        }
        set {
            environment.setValue(newValue, propertyKeyPath, at: identifier)
            environment.telemetry.log(event: UnstructuredMutation(context: context, keyPath: "\(propertyKeyPath):\(identifier)", value: newValue))
        }
    }
}
