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


/// **SwiftUI** property wrapper that provides read only access to the value by ``Property`` KeyPath on ``AtomicState``from the view environment.
@propertyWrapper
@MainActor public struct Observe<State: AtomicState, Value>: DynamicProperty {
    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer = ObservedObjectWillChangeNotification()
    
    let propertyKeyPath: KeyPath<State, Property<Value>>
    
    public init(_ propertyKeyPath: KeyPath<State, Property<Value>>) {
        self.propertyKeyPath = propertyKeyPath
    }
    
    public init<WrappedProperty: PropertyModifier>(
        _ propertyKeyPath: KeyPath<State, WrappedProperty>
    ) where WrappedProperty.Value == Value {
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
    }
    
    public var wrappedValue: Value {
        get {
            environment.subscribe(Observer(observer), on: propertyKeyPath)
            return environment.getValue(propertyKeyPath)
        }
    }
}

