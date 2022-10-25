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

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

/// Provides an observed read-only access to the value of the atomic state type.
@MainActor @propertyWrapper public final class Observe<Value> {

    @Injected(\.decide.storage) var storage

    public var wrappedValue: Value {
        get { getValue(storage.instance.storageReader) }
    }    

    private let getValue: @MainActor (StorageReader) -> Value

    init(getValue: @MainActor @escaping (StorageReader) -> Value) {
        self.getValue = getValue
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Bind
//===----------------------------------------------------------------------===//

/// Provides an observed read/write access to the value of the atomic state type.
@MainActor @propertyWrapper public final class Bind<Value> {
    @Injected(\.decide.storage) var storage

    public var wrappedValue: Value {
        get { getValue(storage.instance.storageReader) }
        set { setValue(storage.instance.storageWriter, newValue) }
    }

    private let getValue: @MainActor (StorageReader) -> Value
    private let setValue: @MainActor (StorageWriter, Value) -> Void

    init(getValue: @escaping (StorageReader) -> Value, setValue: @escaping (StorageWriter, Value) -> Void) {
        self.getValue = getValue
        self.setValue = setValue
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Observe Collection
//===----------------------------------------------------------------------===//

/// Provides a read-only access to the collection state type
@MainActor @propertyWrapper
public final class ObserveCollection<ID: Hashable, Value> {
    public let wrappedValue: CollectionStateAccess<ID, Value>
    public init(wrappedValue: CollectionStateAccess<ID, Value>) {
        self.wrappedValue = wrappedValue
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Bind Collection
//===----------------------------------------------------------------------===//

/// Provides a read/write access to the collection state type
@MainActor @propertyWrapper
public final class BindCollection<ID: Hashable, Value> {
    public let wrappedValue: MutableCollectionStateAccess<ID, Value>
    public init(wrappedValue: MutableCollectionStateAccess<ID, Value>) {
        self.wrappedValue = wrappedValue
    }
}
