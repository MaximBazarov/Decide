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

@propertyWrapper
@MainActor public struct Bind<S: AtomicState, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer = ObservableValue()

    let propertyKeyPath: KeyPath<S, Property<Value>>

    var property: Property<Value> {
        environment.getProperty(propertyKeyPath)
    }

    public var wrappedValue: Value {
        get {
            property.addObserver(observer)
            return property.wrappedValue
        }
        nonmutating set {
            property.wrappedValue = newValue
        }
    }

    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: {
                property.wrappedValue
            },
            set: {
                property.wrappedValue = $0
            }
        )
    }

    public init(_ propertyKeyPath: KeyPath<S, Property<Value>>) {
        self.propertyKeyPath = propertyKeyPath
    }
}
