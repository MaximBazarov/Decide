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
@MainActor public struct BindKeyed<Identifier: Hashable, State: KeyedState<Identifier>, Value>: DynamicProperty {

    @SwiftUI.Environment(\.stateEnvironment) var environment
    @ObservedObject var observer = ObservedObjectWillChangeNotification()
    let context: Context


    let propertyKeyPath: KeyPath<State, Property<Value>>

    public init(
        _ propertyKeyPath: KeyPath<State, Mutable<Value>>,
        file: String = #fileID,
        line: Int = #line
    ) {
        let context = Context(file: file, line: line)
        self.context = context
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
    }

    public subscript(_ identifier: Identifier) -> Binding<Value> {
        Binding<Value>(
            get: {
                environment.subscribe(
                    Observer(observer),
                    on: propertyKeyPath,
                    at: identifier)
                return environment.getValue(propertyKeyPath, at: identifier)
            },
            set: {
                environment.setValue($0, propertyKeyPath, at: identifier)
                environment.telemetry.log(event: UnstructuredMutation(context: context, keyPath: "\(propertyKeyPath):\(identifier)", value: $0))
            }
        )
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
