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


/// State that represents a collection of values of the same type, accessed by id.
public protocol CollectionState {

    /// Type of the state's value.
    associatedtype Value

    /// Type of the the identifier of the value
    associatedtype ID: Hashable

    /// Default value for the state for given id, used if read before write.
    static func defaultValue(at id: ID) -> Value
}

/// A wrapper of the collection states ``Observe`` to provide a get ``subscript(_:)`` for later access to the value.
@MainActor public class CollectionStateAccess<ID: Hashable, Value> {
    /// Read-only access to the value of the ``CollectionState``
    public subscript(_ id: ID) -> Value {
        get { getValue() }
    }

    func getValue() -> Value { fatalError() }
}

/// A wrapper of the collection states ``Bind`` to provide a get/set ``subscript(_:)`` for later access to the value.
@MainActor public class MutableCollectionStateAccess<ID: Hashable, Value>: CollectionStateAccess<ID, Value> {

    /// Read/write access to the value of the ``CollectionState``
    public override subscript(_ id: ID) -> Value {
        get { super.getValue() }
        set { setValue(newValue) }
    }

    func setValue(_ newValue: Value) { fatalError() }
}
