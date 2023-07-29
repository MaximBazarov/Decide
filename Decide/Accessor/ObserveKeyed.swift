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

/// **SwiftUI** property wrapper that provides read only access to the value by ``Property`` KeyPath and a Key on ``KeyedState`` from the view environment.
@propertyWrapper
@MainActor public struct ObserveKeyed<I: Hashable, S: KeyedState<I>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer: ObservableValue

    public var wrappedValue: KeyedValueObserve<I, S, Value>

    public init(_ propertyKeyPath: KeyPath<S, Property<Value>>) {
        let observer = ObservableValue()
        self.observer = observer
        self.wrappedValue = KeyedValueObserve(propertyKeyPath, observer)
    }
    
}
