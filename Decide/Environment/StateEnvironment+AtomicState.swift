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

extension StateEnvironment {
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
}
