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
@MainActor public struct Observe<
    State: AtomicState,
    Value
>: DynamicProperty {
    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer = ObservedObjectWillChangeNotification()

    let containerKeyPath: ValueContainerKeyPath<State, Value>

    public var wrappedValue: Value {
        get {
            switch containerKeyPath {
            case .property(let keyPath):
                environment.subscribe(Observer(observer), on: keyPath)
                return environment.getValue(keyPath)
            case .computed(let keyPath):
                fatalError()
            }
        }
    }
}

