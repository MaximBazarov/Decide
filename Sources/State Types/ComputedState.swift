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


/// State that computes it's value based on other state's values
public protocol ComputedState {
    /// Type of the state's value
    associatedtype Value

    /// Computes the value using `Reader` function to read other states
    static func computed(/*read: Reader*/) -> Value

    /// Should the result of ``ComputedState/computed()`` be stored in the ``StorageSystem``
    var shouldPersistValueInStorage: Bool { get }
}

extension ComputedState {
    /// By default doesn't store the result of ``ComputedState/computed()`` in the ``StorageSystem``
    var shouldPersistValueInStorage: Bool { false }
}

@MainActor public extension Observe {

    /// Read-only access to the value of the ``ComputedState``
    convenience init<T: ComputedState>(_ type: T.Type) where T.Value == Value {
        let key = StorageKey.atom(ObjectIdentifier(type))
        let storage = Storage()
        let defaultValue = type.computed
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
    convenience init<T: ComputedState>(_ type: T.Type) where T.Value == Value {
        let key = StorageKey.atom(ObjectIdentifier(type))
        let storage = Storage()
        let defaultValue = type.computed
        self.init(
            getValue: { storage.getValue(
                for: key,
                onBehalf: key,
                defaultValue: defaultValue
            )},
            setValue: { storage.setValue(
                $0,
                for: key,
                onBehalf: key
            )}
        )
    }
}
