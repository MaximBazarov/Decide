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
@MainActor public struct DefaultObserve<State: AtomicState, Value> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<State, Property<Value>>

    public init(_ keyPath: KeyPath<State, Property<Value>>) {
        self.propertyKeyPath = keyPath
    }

    public init<WrappedProperty: PropertyModifier>(
        _ keyPath: KeyPath<State, WrappedProperty>
    ) where WrappedProperty.Value == Value {
        propertyKeyPath = keyPath.appending(path: \.wrappedValue)
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            let environment = instance.environment
            storage.environment = environment
            environment.subscribe(Observer(instance), on: propertyKeyPath)
            return environment.getValue(propertyKeyPath)
        }
        set {
            /// https://github.com/apple/swift/issues/67561
            /// due to the bug we cannot have subscripts without a setter in property wrappers so this does nothing.
        }
    }

    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}
