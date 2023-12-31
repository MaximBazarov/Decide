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


//===----------------------------------------------------------------------===//
// MARK: - SwiftUI View Environment
//===----------------------------------------------------------------------===//

#if canImport(SwiftUI)
import SwiftUI

/** Property wrapper that provides two-way access to the value
 by ``ObservableState`` KeyPath on ``AtomicStorage``from the view environment.
 */
@propertyWrapper
@MainActor 
public struct Observe<Storage: AtomicStorage, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var binding: ObservableState<Value>.Binding

    public init(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            ref: ObservableState<Value>.Reference(
                state: { $0.observableState(keyPath) },
                debugDescription: String(describing: keyPath)
            ),
            context: Context(file: file, line: line)
        )
    }

    public var wrappedValue: Value {
        get { binding.getValue(in: environment, observer: Observer(binding)) }
    }
}

/**


 */
@propertyWrapper
@MainActor public struct Bind<Storage: AtomicStorage, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var binding: ObservableState<Value>.Binding

    public init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            ref: ObservableState<Value>.Reference(
                state: { $0.observableState(keyPath.appending(path: \.wrappedValue)) },
                debugDescription: String(describing: keyPath)
            ),
            context: Context(file: file, line: line)
        )
    }

    public var wrappedValue: Value {
        get { binding.getValue(in: environment, observer: Observer(binding)) }
        nonmutating set { binding.setValue(in: environment, newValue: newValue) }
    }

    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

#endif


//===----------------------------------------------------------------------===//
// MARK: - Default Environment
//===----------------------------------------------------------------------===//

@propertyWrapper
@MainActor public struct DefaultObserve<Storage: AtomicStorage, Value> {
    @DefaultEnvironment var environment
    var binding: ObservableState<Value>.Binding

    public init(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            ref: ObservableState<Value>.Reference(
                state: { $0.observableState(keyPath) },
                debugDescription: String(describing: keyPath)
            ),
            context: Context(file: file, line: line)
        )
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            return storage.binding.getValue(in: storage.environment, observer: Observer(instance))
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            return storage.binding.setValue(in: storage.environment, newValue: newValue)
        }
    }

    @available(*, unavailable, message: "@DefaultObserve can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: Value {
        get { fatalError() }
        nonmutating set { fatalError() }
    }
}


/**


 */
@propertyWrapper
@MainActor public struct DefaultBind<Storage: AtomicStorage, Value>: DynamicProperty {

    @DefaultEnvironment var environment
    @ObservedObject var binding: ObservableState<Value>.Binding

    public init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            ref: ObservableState<Value>.Reference(
                state: { $0.observableState(keyPath.appending(path: \.wrappedValue)) },
                debugDescription: String(describing: keyPath)
            ),
            context: Context(file: file, line: line)
        )
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            return storage.binding.getValue(in: storage.environment, observer: Observer(instance))
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            return storage.binding.setValue(in: storage.environment, newValue: newValue)
        }
    }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: Value {
        get { fatalError() }
        nonmutating set { fatalError() }
    }
}
