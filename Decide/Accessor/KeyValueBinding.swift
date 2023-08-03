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

import SwiftUI

@MainActor public struct KeyedValueBinding<I: Hashable, S: KeyedState<I>, Value> {
    unowned var environment: ApplicationEnvironment

    let observer: Observer
    let propertyKeyPath: KeyPath<S, Property<Value>>

    init(
        bind propertyKeyPath: KeyPath<S, Property<Value>>,
        observer: Observer,
        environment: ApplicationEnvironment
    ) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
        self.environment = environment
    }

    public subscript(_ identifier: I) -> Binding<Value> {
        Binding<Value>(
            get: {
                environment.subscribe(observer, on: propertyKeyPath, at: identifier)
                return environment.getValue(propertyKeyPath, at: identifier)
            },
            set: {
                return environment.setValue($0, propertyKeyPath, at: identifier)
            }
        )
    }
}
