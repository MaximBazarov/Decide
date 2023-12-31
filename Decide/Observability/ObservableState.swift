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
public protocol ObservableValueWrapper {
    associatedtype Value
    var storage: ValueStorage<Value> { get }
}


@MainActor
public final class ValueStorage<Value> {
    public var initialValue: () -> Value
    public var value: Value {
        get {
            if let value = _value {
                return value
            }

            let newValue = initialValue()
            _value = newValue
            return newValue
        }
        set {
            _value = newValue
        }
    }

    var _value: Value?
    init(
        initialValue: @escaping () -> Value
    ) {
        self.initialValue = initialValue
    }
}

/**
 A wrapper that wraps the ``ValueStorage``.
 **Observability**: guaranties that any change in the value cause a notification to all observers
 */
@propertyWrapper
@MainActor
public final class ObservableValue<Value> {
    
    public var wrappedValue: Value {
        valueStorage.value
    }

    public var projectedValue: ObservableValue<Value> { self }

    var valueStorage: ValueStorage<Value>
    private var observation = ObserverStorage()

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.valueStorage = ValueStorage(initialValue: wrappedValue)
    }

    public init<Wrapper: ObservableValueWrapper>(wrappedValue: Wrapper) where Wrapper.Value == Value {
        self.valueStorage = wrappedValue.storage
    }
}

extension ObservableValue {
    public func getValueSubscribing(observer: Observer) -> Value {
        observation.subscribe(observer)
        return wrappedValue
    }

    public func set(value newValue: Value) {
        valueStorage.value = newValue
        observation.sendAll()
    }
}



