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

/// **SwiftUI** property wrapper that provides two-way access to the value by ``Property`` KeyPath on ``KeyedState`` from the view environment.
@propertyWrapper
@MainActor public struct BindKeyed<I: Hashable, S: KeyedState<I>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer: ObservableValue

    public var wrappedValue: KeyedValueObserve<I, S, Value>
    public var projectedValue: KeyedValueBinding<I, S, Value>

    public init(_ propertyKeyPath: KeyPath<S, Property<Value>>) {
        let observer = ObservableValue()
        self.observer = observer
        self.wrappedValue = KeyedValueObserve(propertyKeyPath, observer)
        self.projectedValue = KeyedValueBinding(propertyKeyPath, observer)
    }
}

@MainActor public struct KeyedValueObserve<I: Hashable, S: KeyedState<I>, Value> {
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

