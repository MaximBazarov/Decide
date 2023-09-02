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
@MainActor public struct DefaultBind<State: AtomicState, Value> {
    @DefaultEnvironment var environment

    private let propertyKeyPath: KeyPath<State, Property<Value>>
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
            let storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            let environment = instance.environment
            storage.environment = environment
            environment.setValue(newValue, propertyKeyPath)
            environment.telemetry.log(event: UnstructuredMutation(context: storage.context, keyPath: "\(propertyKeyPath)", value: newValue))
        }
    }
    
    public var projectedValue: Self { self }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}
