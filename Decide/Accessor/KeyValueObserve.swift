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

@MainActor public struct KeyedValueObserve<I: Hashable, S: KeyedState<I>, Value> {
    unowned var environment: ApplicationEnvironment

    var observer: Observer?
    let propertyKeyPath: KeyPath<S, Property<Value>>

    public subscript(_ identifier: I) -> Value {
        get {
            if let observer {
                environment.subscribe(observer, on: propertyKeyPath, at: identifier)
            }
            return environment.getValue(propertyKeyPath, at: identifier)
        }
    }

    init(
        bind propertyKeyPath: KeyPath<S, Property<Value>>,
        observer: Observer,
        environment: ApplicationEnvironment
    ) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
        self.environment = environment
    }
}
