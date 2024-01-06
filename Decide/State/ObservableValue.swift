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


/**
 Contains the reference to the storage of the value.
 */
@MainActor
public protocol ObservableValueStorageWrapper {
    associatedtype Value
    var storage: ValueStorage<Value> { get }
    var projectedValue: Self { get }
}

/**
 A wrapper that wraps the ``ValueStorage``.
 **Observability**: guaranties that any change in the value cause a notification to all observers
 */
@propertyWrapper
@MainActor
public final class ObservableValue<Value>: ObservableValueStorageWrapper {
    public var wrappedValue: Value {
        storage.value
    }

    public var projectedValue: ObservableValue<Value> { self }

    public var storage: ValueStorage<Value>

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.storage = ValueStorage(initialValue: wrappedValue)
    }

    public init<Wrapper: ObservableValueStorageWrapper>(wrappedValue: Wrapper) where Wrapper.Value == Value {
        self.storage = wrappedValue.storage
    }
}
