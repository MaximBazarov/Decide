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

@propertyWrapper
@MainActor public struct EnvironmentValue<S: State, Value> {

    public typealias PropertyKeyPath = KeyPath<S, Property<Value>>

    private let propertyKeyPath: PropertyKeyPath

    public init(_ keyPath: KeyPath<S, Property<Value>>) {
        self.propertyKeyPath = keyPath
    }

    public static subscript<EnclosingObject: EnvironmentManagedObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Value {
        get {
            let storage: Self = instance[keyPath: storageKeyPath]
            let propertyKeyPath: KeyPath<S, Property<Value>> = storage.propertyKeyPath
            let environment: StateEnvironment = instance.environment
            let property: Property<Value> = environment.getProperty(propertyKeyPath)
            return property.wrappedValue
        }
        set {
            let propertyKeyPath: KeyPath<S, Property<Value>> = instance[keyPath: storageKeyPath].propertyKeyPath
            let environment: StateEnvironment = instance.environment
            let property: Property<Value> = environment.getProperty(propertyKeyPath)
            property.wrappedValue = newValue
        }
    }

    @available(*, unavailable, message: "@EnvironmentValue can only be enclosed by Effects or Decisions.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}
