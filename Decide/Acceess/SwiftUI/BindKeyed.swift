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

@MainActor public struct KeyedValueAccess<I: Hashable, S: KeyedState<I>, Value> {
    @SwiftUI.Environment(\.stateEnvironment) var environment

    weak var observer: ObservableValue?
    let propertyKeyPath: KeyPath<S, Property<Value>>

    public subscript(_ identifier: I) -> Value {
        get {
            let property = environment.getProperty(propertyKeyPath, at: identifier)
            if let observer {
                property.addObserver(observer)
            }
            return property.wrappedValue
        }
        nonmutating set {
            let property = environment.getProperty(propertyKeyPath, at: identifier)
            property.wrappedValue = newValue
        }
    }

    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: {
                fatalError()
            },
            set: {_ in
                fatalError()
            }
        )
    }

    init(_ propertyKeyPath: KeyPath<S, Property<Value>>, _ observer: ObservableValue) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
    }
}

@MainActor public struct KeyedValueBinding<I: Hashable, S: KeyedState<I>, Value> {
    @SwiftUI.Environment(\.stateEnvironment) var environment

    weak var observer: ObservableValue?
    let propertyKeyPath: KeyPath<S, Property<Value>>

    public subscript(_ identifier: I) -> Binding<Value> {
        Binding<Value>(
            get: {
                let property = environment.getProperty(propertyKeyPath, at: identifier)
                if let observer {
                    property.addObserver(observer)
                }
                return property.wrappedValue
            },
            set: {
                let property = environment.getProperty(propertyKeyPath, at: identifier)
                property.wrappedValue = $0
            }
        )
    }

    init(_ propertyKeyPath: KeyPath<S, Property<Value>>, _ observer: ObservableValue) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
    }
}

@propertyWrapper
@MainActor public struct BindKeyed<I: Hashable, S: KeyedState<I>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer: ObservableValue

    public var wrappedValue: KeyedValueAccess<I, S, Value>
    public var projectedValue: KeyedValueBinding<I, S, Value>

    public init(_ propertyKeyPath: KeyPath<S, Property<Value>>) {
        let observer = ObservableValue()
        self.observer = observer
        self.wrappedValue = KeyedValueAccess(propertyKeyPath, observer)
        self.projectedValue = KeyedValueBinding(propertyKeyPath, observer)
    }
}
