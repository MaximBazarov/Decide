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

extension ObservableState {
    /**
     Binds to the provided KeyPath to the ``ObservableState`` or KeyPath + ID.
     on get calls the provided `subscribe` closure.
     on set calls the sendAll on observers.
     */
    @MainActor final class Binding: ObservableObject {
        private let stateRef: Reference
        private let context: Context

        init(ref: Reference, context: Context) {
            self.stateRef = ref
            self.context = context
        }

        func getValue(
            in environment: ApplicationEnvironment,
            observer: Observer?
        ) -> Value {
            let state = stateRef.state(environment)
            if let observer {
                state.observerStorage.subscribe(observer)
            }
            return state.wrappedValue
        }

        func setValue(
            in environment: ApplicationEnvironment,
            newValue: Value
        ) {
            let state = stateRef.state(environment)
            state.wrappedValue = newValue
            state.observerStorage.sendAll()
        }
    }
}

/// Marks observableState as mutable, to use in bindings e.g. ``Bind``
@propertyWrapper @MainActor public final class Mutable<Value> {
    private(set) public var wrappedValue: ObservableState<Value>
    public var projectedValue: Mutable<Value> { self }
    public init(wrappedValue: ObservableState<Value>) {
        self.wrappedValue = wrappedValue
    }
}

public extension Observe {
    init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.init(keyPath.appending(path: \.wrappedValue),file: file, line: line)
    }
}

public extension DefaultObserve {
    init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.init(keyPath.appending(path: \.wrappedValue),file: file, line: line)
    }
}

public extension ObserveKeyed {
    init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.init(keyPath.appending(path: \.wrappedValue),file: file, line: line)
    }
}

public extension DefaultObserveKeyed {
    init(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.init(keyPath.appending(path: \.wrappedValue),file: file, line: line)
    }
}

public extension DecisionEnvironment {
    subscript<Storage: AtomicStorage, Value>(
        _ keyPath: KeyPath<Storage, Mutable<Value>>
    ) -> Value {
        get {
            self[keyPath.appending(path: \.wrappedValue)]
        }
        set {
            self[keyPath.appending(path: \.wrappedValue)] = newValue
        }
    }

    subscript<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        at identifier: Identifier
    ) -> Value {
        get {
            self[keyPath.appending(path: \.wrappedValue), at: identifier]
        }
        set {
            self[keyPath.appending(path: \.wrappedValue), at: identifier] = newValue
        }
    }
}

extension EffectEnvironment {}

