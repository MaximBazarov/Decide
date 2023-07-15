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
@MainActor public struct DefaultBind<S: AtomicState, Value> {
    @DefaultEnvironment var environment

    public typealias PropertyKeyPath = KeyPath<S, Property<Value>>

    private let propertyKeyPath: PropertyKeyPath

    public init(_ keyPath: KeyPath<S, Property<Value>>) {
        self.propertyKeyPath = keyPath
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            storage.environment = instance.environment
            let property = storage.environment.getProperty(propertyKeyPath)
            property.observationSystem.subscribe(instance)
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
