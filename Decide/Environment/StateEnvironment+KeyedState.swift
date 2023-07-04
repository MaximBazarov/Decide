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
    subscript<I:Hashable, S: KeyedState<I>>(_ stateType: S.Type, _ identifier: I) -> S {
        let key = Key.keyed(ObjectIdentifier(stateType), identifier)
        if let state = storage[key] as? S { return state }
        let newValue = S.init()
        storage[key] = newValue
        return newValue
    }

    func getProperty<I:Hashable, S: KeyedState<I>, Value>(
        _ propertyKeyPath: KeyPath<S, Property<Value>>,
        at identifier: I
    ) -> Property<Value> {
        self[S.self, identifier][keyPath: propertyKeyPath]
    }
}
