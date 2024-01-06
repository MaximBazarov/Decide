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

import Foundation

#if canImport(SwiftUI)
// MARK: - SwiftUI -
import SwiftUI

@propertyWrapper
@MainActor
public struct SwiftUIBind<
    Root: StateRoot,
    Value,
    Mutation: ValueDecision
>: DynamicProperty  {
    @SwiftUI.Environment(\.sharedEnvironment) var environment
    @ObservedObject var publisher = ChangesPublisher()

    public var wrappedValue: Value {
        get {
            environment
                .get(Root.self)[keyPath: statePath.appending(path: \.storage)]
                .getValueSubscribing(
                    observer: Observer(publisher) { [weak publisher] in
                        publisher?.objectWillChange.send()
                    }
                )
        }
        nonmutating set {
            environment
                .get(Root.self)[keyPath: statePath.appending(path: \.storage)]
                .set(value: newValue)
        }
    }

    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: {
                self.wrappedValue
            },
            set: { newValue, _ in
                self.wrappedValue = newValue
            }
        )
    }

    let statePath: KeyPath<Root, ObservableValue<Value>>
    let mutate: Mutation.Type

    public init(
        _ statePath: KeyPath<Root, ObservableValue<Value>>,
        mutate: Mutation.Type
    ) {
        self.statePath = statePath
        self.mutate = mutate
    }
}
#endif
