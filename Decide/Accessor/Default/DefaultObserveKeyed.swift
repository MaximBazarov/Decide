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
    I: Hashable,
    S: KeyedState<I>,
    Value
> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<S, Property<Value>>
    private var valueObserve: KeyedValueObserve<I, S, Value>?

    public init(
        _ keyPath: KeyPath<S, Property<Value>>
    ) {
        propertyKeyPath = keyPath
    }

    public init<P: PropertyModifier>(
        _ keyPath: KeyPath<S, P>
    ) where P.Value == Value {
        propertyKeyPath = keyPath.appending(path: \.wrappedValue)
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, KeyedValueObserve<I, S, Value>>,
        storage storageKeyPath: WritableKeyPath<EnclosingObject, Self>
    ) -> KeyedValueObserve<I, S, Value> {
        get {
            var storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            let environment = instance.environment
            storage.environment = environment
            let observer = Observer(instance)
            if storage.valueObserve == nil {
                storage.valueObserve = KeyedValueObserve<I, S, Value>(
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
    public var wrappedValue: KeyedValueObserve<I, S, Value> {
        get { fatalError() }
        set { fatalError() }
    }
}
