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
    typealias StateKey = ObjectIdentifier

    static let `default` = StateEnvironment()

    var storage: [StateKey: Any] = [:]

    subscript<S: State>(_ stateType: S.Type) -> S {
        let stateKey = StateKey(stateType)
        if let state = storage[stateKey] as? S { return state }
        let newValue = S.init()
        storage[stateKey] = newValue
        return newValue
    }

    func getProperty<S: State, Value>(_ propertyKeyPath: KeyPath<S, Property<Value>>) -> Property<Value> {
        self[S.self][keyPath: propertyKeyPath]
    }

    public init() {}
}

