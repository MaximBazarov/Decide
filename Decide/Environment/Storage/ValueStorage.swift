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


/// Storage for the value. Must at all times be the single source of truth.
@MainActor open class ValueStorage<Value> {
    @MainActor func setValue(_ newValue: Value) {}
    @MainActor func getValue() -> Value { preconditionFailure("\(#function) must be implemented in a sunclass") }
}


/// Stores the value only if it was written.
/// Holds the closure to spawn the initital value if it was read before that.
final class LazyValueStorage<Value>: ValueStorage<Value> {
    public var initialValue: () -> Value

    var _value: Value?

    init(initialValue: @escaping () -> Value) {
        self.initialValue = initialValue
    }

    override func setValue(_ newValue: Value) {
        _value = newValue
    }

    override func getValue() -> Value {
        if let value = _value {
            return value
        }

        let newValue = initialValue()
        _value = newValue
        return newValue
    }
}
