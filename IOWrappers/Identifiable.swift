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

import Combine

#if canImport(SwiftUI)
import SwiftUI

@propertyWrapper
@MainActor public struct ObserveKeyed<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var binding: LazyBinding<Identifier, Storage, Value>

    public init(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            keyPath: keyPath,
            context: Context(file: file, line: line)
        )
    }

    public subscript(_ identifier: Identifier) -> Value {
        get { binding.bound(id: identifier).getValue(in: environment, observer: Observer(binding)) }
    }

    public var wrappedValue: Self {
        self
    }
}


@propertyWrapper
@MainActor public struct BindKeyed<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var binding: LazyBinding<Identifier, Storage, Value>

    public init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            keyPath: keyPath.appending(path: \.wrappedValue),
            context: Context(file: file, line: line)
        )
    }

    public subscript(_ identifier: Identifier) -> Binding<Value> {
        Binding<Value>(
            get: { binding.bound(id: identifier).getValue(in: environment, observer: Observer(binding)) },
            set: { binding.bound(id: identifier).setValue(in: environment, newValue: $0) }
        )
    }

    public subscript(_ identifier: Identifier) -> Value {
        get { binding.bound(id: identifier).getValue(in: environment, observer: Observer(binding)) }
    }

    public var wrappedValue: Self {
        self
    }
}
#endif


@propertyWrapper
@MainActor public struct DefaultObserveKeyed<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value> {
    @DefaultEnvironment var environment
    @ObservedObject var binding: LazyBinding<Identifier, Storage, Value>
    
    @MainActor public final class StateForKey {
        weak var enclosedInstance: EnvironmentObservingObject?
        unowned var binding: LazyBinding<Identifier, Storage, Value>
        unowned var environment: ApplicationEnvironment

        init(
            enclosedInstance: EnvironmentObservingObject?,
            binding: LazyBinding<Identifier, Storage, Value>,
            environment: ApplicationEnvironment
        ) {
            self.enclosedInstance = enclosedInstance
            self.binding = binding
            self.environment = environment
        }

        public subscript(_ identifier: Identifier) -> Value {
            get {
                var observer: Observer?
                if let enclosedInstance {
                    observer = Observer(enclosedInstance)
                }
                return binding
                    .bound(id: identifier)
                    .getValue(in: environment, observer: observer)
            }
        }
    }

    public init(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            keyPath: keyPath,
            context: Context(file: file, line: line)
        )
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, StateForKey>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> StateForKey {
        get {
            let storage = instance[keyPath: storageKeyPath]
            return StateForKey(
                enclosedInstance: instance,
                binding: storage.binding,
                environment: storage.environment
            )
        }
        set {}
    }

    @available(*, unavailable, message: "@DefaultObserveKeyed can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: StateForKey {
        fatalError()
    }
}

@propertyWrapper
@MainActor public struct DefaultBindKeyed<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value> {
    @DefaultEnvironment var environment
    @ObservedObject var binding: LazyBinding<Identifier, Storage, Value>

    public init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.binding = .init(
            keyPath: keyPath.appending(path: \.wrappedValue),
            context: Context(file: file, line: line)
        )
    }

    @MainActor public final class StateForKey {
        weak var enclosedInstance: EnvironmentObservingObject?
        unowned var binding: LazyBinding<Identifier, Storage, Value>
        unowned var environment: ApplicationEnvironment

        init(
            enclosedInstance: EnvironmentObservingObject?,
            binding: LazyBinding<Identifier, Storage, Value>,
            environment: ApplicationEnvironment
        ) {
            self.enclosedInstance = enclosedInstance
            self.binding = binding
            self.environment = environment
        }

        public subscript(_ identifier: Identifier) -> Value {
            get {
                var observer: Observer?
                if let enclosedInstance {
                    observer = Observer(enclosedInstance)
                }
                return binding
                    .bound(id: identifier)
                    .getValue(in: environment, observer: observer)
            }
            set {
                binding
                    .bound(id: identifier)
                    .setValue(in: environment, newValue: newValue)
            }
        }
    }

    public static subscript<EnclosingObject: EnvironmentObservingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, StateForKey>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> StateForKey {
        get {
            let storage = instance[keyPath: storageKeyPath]
            return StateForKey(
                enclosedInstance: instance,
                binding: storage.binding,
                environment: storage.environment
            )
        }
        set {}
    }


    @available(*, unavailable, message: "@DefaultObserveKeyed can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: StateForKey {
        fatalError()
    }
}


/**
 We need id to use a keyed state accessors e.g. `@ObserveKeyed(...)`
 but we can't get it, since it's a static initializer we don't have
 access to the instance hence none of its properties,
 so user can't possibly have an id at this point.

 The idea here is to prepare everything and create a binding on the fly
 once we have an id.
 */
@MainActor final class LazyBinding<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>: ObservableObject {
    let keyPath: KeyPath<Storage, ObservableState<Value>>
    let context: Context

    init(keyPath: KeyPath<Storage, ObservableState<Value>>, context: Context) {
        self.keyPath = keyPath
        self.context = context
    }

    func bound(id: Identifier) -> ObservableState<Value>.Binding {
        let stateReference = ObservableState<Value>.Reference.init(
            state: { environment in
                environment.observableState(self.keyPath, at: id)
            },
            debugDescription: "("+String(describing: keyPath) + " at: \(id))"
        )

        let binding = ObservableState<Value>.Binding.init(ref: stateReference, context: context)
        return binding
    }
}
