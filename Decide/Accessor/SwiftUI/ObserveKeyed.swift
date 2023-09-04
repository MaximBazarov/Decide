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

    let containerKeyPath: ValueContainerKeyPath<State, Value>

    public subscript(_ identifier: Identifier) -> Value {
        get {
            switch containerKeyPath {
            case .property(let keyPath):
                environment.subscribe(Observer(observer), on: keyPath, at: identifier)
                return environment.getValue(keyPath, at: identifier)
            case .computed(let keyPath):
                fatalError()
            }

        }
    }

    public var wrappedValue: Self {
        self
    }
}
