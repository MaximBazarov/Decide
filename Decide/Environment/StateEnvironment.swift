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

@MainActor public final class StateEnvironment {
    enum Key: Hashable {
        case atomic(ObjectIdentifier)
        case keyed(ObjectIdentifier, AnyHashable)
    }

    static let `default` = StateEnvironment()

    var storage: [Key: Any] = [:]

    subscript<S: AtomicState>(_ stateType: S.Type) -> S {
        let stateKey = StateKey(stateType)
        if let state = storage[stateKey] as? S { return state }
        let newValue = S.init()
        storage[stateKey] = newValue
        return newValue
    }

    func getProperty<S: AtomicState, Value>(_ propertyKeyPath: KeyPath<S, Property<Value>>) -> Property<Value> {
        self[S.self][keyPath: propertyKeyPath]
    }

    public init() {}
}
