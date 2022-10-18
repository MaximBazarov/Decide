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


/// Value that exist only once per ``StorageSystem``
public protocol AtomicState {
    /// Type of the state's value.
    associatedtype Value

    /// Default value for the state, used if read before write.
    static func defaultValue() -> Value
}

@MainActor public extension Observe {

    /// Read-only access to the value of the ``AtomicState``
    convenience init<T: AtomicState>(_ type: T.Type) where T.Value == Value {
        let key = StorageKey.atom(ObjectIdentifier(type))
        let storage = Storage()
        let defaultValue = type.defaultValue
        self.init(
            getValue: { storage.getValue(
                for: key,
                onBehalf: key,
                defaultValue: defaultValue
            )}
        )
    }
}

@MainActor public extension Bind {
    /// Read/write access to the value of the ``AtomicState``
    convenience init<T: AtomicState>(_ type: T.Type) where T.Value == Value {
        let key = StorageKey.atom(ObjectIdentifier(type))
        let storage = Storage()
        self.init(
            getValue: { storage.getValue(
                for: key,
                onBehalf: key,
                defaultValue: type.defaultValue
            )},
            setValue: { storage.setValue(
                $0,
                for: key,
                onBehalf: key
            )}
        )
    }
}
