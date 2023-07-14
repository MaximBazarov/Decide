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


@MainActor public protocol EnvironmentObservingObject: EnvironmentManagedObject {
    @MainActor func environmentDidUpdate()
}

@propertyWrapper
@MainActor public struct DefaultBind<S: AtomicState, Value> {

    public typealias PropertyKeyPath = KeyPath<S, Property<Value>>

    private let propertyKeyPath: PropertyKeyPath

    public init(_ keyPath: KeyPath<S, Property<Value>>) {
        self.propertyKeyPath = keyPath
    }
    
    var environment: ApplicationEnvironment = .default

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Value {
        get {
            var storage: Self = instance[keyPath: storageKeyPath]
            let propertyKeyPath: KeyPath<S, Property<Value>> = storage.propertyKeyPath
            storage.environment = instance.environment
            let property: Property<Value> = storage.environment.getProperty(propertyKeyPath)
            
            return property.wrappedValue
        }
        set {
            let propertyKeyPath: KeyPath<S, Property<Value>> = instance[keyPath: storageKeyPath].propertyKeyPath
            let environment: ApplicationEnvironment = instance.environment
            let property: Property<Value> = environment.getProperty(propertyKeyPath)
            property.wrappedValue = newValue
        }
    }
    
    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@EnvironmentValue can only be enclosed by Effects or Decisions.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}
