//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import Inject

// MARK: - Atomic

/// Provides a read-only access to the ```` state type
@MainActor @propertyWrapper public final class Observe<Value> {
    public var wrappedValue: Value {
        get { getValue() }
    }    

    private var getValue: @MainActor () -> Value

    init(getValue: @escaping () -> Value) {
        self.getValue = getValue
    }
}

/// Provides a read/write access to the atomic state type
@MainActor @propertyWrapper public final class Bind<Value> {
    public var wrappedValue: Value {
        get { getValue() }
        set { setValue(newValue) }
    }

    private var getValue: @MainActor () -> Value
    private var setValue: @MainActor (Value) -> Void

    init(
        getValue: @escaping () -> Value,
        setValue: @escaping (Value) -> Void
    ) {
        self.getValue = getValue
        self.setValue = setValue
    }
}

// MARK: - Collection

/// Provides a read-only access to the collection state type
@MainActor @propertyWrapper
public final class ObserveCollection<ID: Hashable, Value> {
    public let wrappedValue: CollectionStateAccess<ID, Value>
    public init(wrappedValue: CollectionStateAccess<ID, Value>) {
        self.wrappedValue = wrappedValue
    }
}

/// Provides a read/write access to the collection state type
@MainActor @propertyWrapper
public final class BindCollection<ID: Hashable, Value> {
    public let wrappedValue: MutableCollectionStateAccess<ID, Value>
    public init(wrappedValue: MutableCollectionStateAccess<ID, Value>) {
        self.wrappedValue = wrappedValue
    }
}

