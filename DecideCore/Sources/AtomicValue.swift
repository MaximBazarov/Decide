// DefaultValue.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

@propertyWrapper
public final class AtomicValue<Value>: AtomicValueStorage {
    var value: Value?

    public init(wrappedValue: @escaping (SharedEnvironment) -> Value) {
        self.wrappedValue = wrappedValue
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = { _ in wrappedValue }
    }

    public var wrappedValue: (SharedEnvironment) -> Value
}
