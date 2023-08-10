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
    @ObservedObject var observer = ObservedObjectWillChangeNotification()

    let propertyKeyPath: KeyPath<S, Property<Value>>

    public init(_ propertyKeyPath: KeyPath<S, Mutable<Value>>) {
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
    }

    public subscript(_ identifier: I) -> Binding<Value> {
        Binding<Value>(
            get: {
                environment.subscribe(
                    Observer(observer),
                    on: propertyKeyPath,
                    at: identifier)
                return environment.getValue(propertyKeyPath, at: identifier)
            },
            set: {
                return environment.setValue($0, propertyKeyPath, at: identifier)
            }
        )
    }

    public subscript(_ identifier: I) -> Value {
        get {
            environment.subscribe(Observer(observer), on: propertyKeyPath, at: identifier)
            return environment.getValue(propertyKeyPath, at: identifier)
        }
    }

    public var wrappedValue: Self {
        self
    }
}
