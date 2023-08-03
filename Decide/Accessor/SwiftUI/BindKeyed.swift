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
    @ObservedObject var observer = ValueWillChangeNotification()

    let propertyKeyPath: KeyPath<S, Property<Value>>

    public init(_ propertyKeyPath: KeyPath<S, Mutable<Value>>) {
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
    }

    public lazy var wrappedValue: KeyedValueObserve<I, S, Value> = {
        return KeyedValueObserve(
            bind: propertyKeyPath,
            observer: Observer(observer),
            environment: environment
        )
    }()

    public lazy var projectedValue: KeyedValueBinding<I, S, Value> = {
        return KeyedValueBinding(
            bind: propertyKeyPath,
            observer: Observer(observer),
            environment: environment
        )
    }()
}
