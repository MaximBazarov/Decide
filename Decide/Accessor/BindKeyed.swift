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

/// **SwiftUI** property wrapper that provides two-way access to the value by ``Property`` KeyPath and a Key on ``KeyedState`` from the view environment.
@propertyWrapper
@MainActor public struct BindKeyed<I: Hashable, S: KeyedState<I>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer: ObservableValue

    public var wrappedValue: KeyedValueObserve<I, S, Value>
    public var projectedValue: KeyedValueBinding<I, S, Value>

    public init(_ propertyKeyPath: KeyPath<S, Mutable<Value>>) {
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
            if let observer {
                environment.subscribe(observer, on: propertyKeyPath, at: identifier)
            }
            return environment.getValue(propertyKeyPath, at: identifier)
        }
    }

    init<P: PropertyModifier>(_ propertyKeyPath: KeyPath<S, P>, _ observer: ObservableValue) where P.Value == Value {
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
        self.observer = observer
    }

    init(_ propertyKeyPath: KeyPath<S, Property<Value>>, _ observer: ObservableValue) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
    }
}

@MainActor public struct KeyedValueBinding<I: Hashable, S: KeyedState<I>, Value> {
    @SwiftUI.Environment(\.stateEnvironment) var environment

    weak var observer: ObservableValue?
    let propertyKeyPath: KeyPath<S, Mutable<Value>>

    public subscript(_ identifier: I) -> Binding<Value> {
        Binding<Value>(
            get: {
                if let observer {
                    environment.subscribe(observer, on: propertyKeyPath, at: identifier)
                }
                return environment.getValue(propertyKeyPath, at: identifier)
            },
            set: {
                return environment.setValue($0, propertyKeyPath, at: identifier)
            }
        )
    }

    init(_ propertyKeyPath: KeyPath<S, Mutable<Value>>, _ observer: ObservableValue) {
        self.propertyKeyPath = propertyKeyPath
        self.observer = observer
    }
}

