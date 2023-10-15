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


/// Managed by ``ApplicationEnvironment`` storage for values that can be observed and mutated.
@propertyWrapper
@MainActor public final class ObservableState<Value> {
    let context: Context
    var value: Value?
    var observerStorage = ObserverStorage()
    var persistencyStrategy: PersistencyStrategy<Value>?

    let defaultValue: () -> Value

    /// Default Value
    public var wrappedValue: Value {
        get {
            if let value { return value }
            let newValue = defaultValue()
            value = newValue
            return newValue
        }
        set {
            value = newValue
        }
    }

    public var projectedValue: ObservableState<Value> {
        self
    }

    public init(
        wrappedValue: @autoclosure @escaping () -> Value,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.defaultValue = wrappedValue
        self.context = Context(file: file, line: line)
    }
}

extension ObservableState {
    struct Reference {
        let state: (ApplicationEnvironment) -> ObservableState<Value>
        let debugDescription: String // encoded keypath or keypath + id
    }
}
