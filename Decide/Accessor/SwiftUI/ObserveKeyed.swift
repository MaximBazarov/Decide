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
@MainActor public struct ObserveKeyed<
    Identifier: Hashable,
    State: KeyedState<Identifier>,
    Value
>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer = ObservedObjectWillChangeNotification()

    let propertyKeyPath: KeyPath<State, Property<Value>>

    public init(_ propertyKeyPath: KeyPath<State, Property<Value>>) {
        self.propertyKeyPath = propertyKeyPath
    }

    public init<P: PropertyModifier>(
        _ propertyKeyPath: KeyPath<State, P>
    ) where P.Value == Value {
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
    }

    public subscript(_ identifier: Identifier) -> Value {
        get {
            environment.subscribe(Observer(observer), on: propertyKeyPath, at: identifier)
            return environment.getValue(propertyKeyPath, at: identifier)
        }
    }

    public var wrappedValue: Self {
        self
    }
}
