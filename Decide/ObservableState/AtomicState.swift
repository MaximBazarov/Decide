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


/// AtomicState is a managed by ``ApplicationEnvironment`` container for ``Property`` and ``DefaultInstance`` definitions,
/// its only requirement is to provide standalone `init()` so ``ApplicationEnvironment`` can instantiate it when necessary.
/// You should never use instances of ``AtomicState`` directly, use ``Property`` or ``DefaultInstance`` instead.
///
/// **Usage:**
/// ```swift
/// final class TestState: AtomicState {
///     // Declaration of a AtomicState property with a string value
///     // that is "default-value" by default.
///     @Property var name: String = "default-value"
///
///     // Declaration of the instance of a `NetworkingInterface` protocol
///     // that is `Networking()` by default.
///     @DefaultInstance var networking: NetworkingInterface = Networking()
/// }
/// ```
@MainActor open class AtomicState {
    required public init() {}
}


extension ApplicationEnvironment {
    subscript<S: AtomicState>(_ stateType: S.Type) -> S {
        let key = Key.atomic(ObjectIdentifier(stateType))
        if let state = storage[key] as? S { return state }
        let newValue = S.init()
        storage[key] = newValue
        return newValue
    }

    func getProperty<S: AtomicState, Value>(_ propertyKeyPath: KeyPath<S, Property<Value>>) -> Property<Value> {
        self[S.self][keyPath: propertyKeyPath]
    }
    
    func getInstance<S: AtomicState, O: AnyObject>(_ instanceKeyPath: KeyPath<S, DefaultInstance<O>>) -> DefaultInstance<O> {
        self[S.self][keyPath: instanceKeyPath]
    }
}
