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


@available(*, unavailable, message: "Not available due to swift bug: https://github.com/apple/swift/issues/67561")
@propertyWrapper
@MainActor public struct DefaultObserve<S: AtomicState, Value> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<S, Mutable<Value>>

    public init(_ keyPath: KeyPath<S, Mutable<Value>>) {
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
            let environment = instance.environment
            // storage.environment = environment // enable when available
            environment.subscribe(instance, on: propertyKeyPath)
            return environment.getValue(propertyKeyPath)
        }
    }

    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}
