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


/// **SwiftUI** property wrapper that provides two-way access to the value by ``Property`` KeyPath on ``AtomicState``from the view environment.
@propertyWrapper
@MainActor public struct Bind<S: AtomicState, Value>: DynamicProperty {
    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer = ObservableValue()

    let propertyKeyPath: KeyPath<S, Mutable<Value>>

    public var wrappedValue: Value {
        get {
            environment.subscribe(observer, on: propertyKeyPath)
            return environment.getValue(propertyKeyPath)
        }
        nonmutating set {
            environment.setValue(newValue, propertyKeyPath)
        }
    }

    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: {
                wrappedValue
            },
            set: {
                wrappedValue = $0
            }
        )
    }

    public init(_ propertyKeyPath: KeyPath<S, Mutable<Value>>) {
        self.propertyKeyPath = propertyKeyPath
    }
}
