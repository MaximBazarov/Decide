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
@MainActor public struct Instance<S: AtomicState, Value> {

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
    }

    @available(*, unavailable, message: "@Instance can only be enclosed in EnvironmentManagedObject.")
    public var wrappedValue: Value {
        get { fatalError() }
    }
}
