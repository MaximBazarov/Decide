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
@MainActor open class KeyValueStorage<Key: Hashable, Value> {
    @MainActor func setValue(_ newValue: Value, at: Key) {}
    @MainActor func getValue(at: Key) -> Value { preconditionFailure("\(#function) must be implemented in a sunclass") }
}


/// Stores the value only if it was written.
/// Holds the closure to spawn the initital value if it was read before that.
final class LazyKeyValueStorage<Key: Hashable, Value>: KeyValueStorage<Key, Value> {
    public var initialValue: (Key) -> Value

    private var _value: [Key: Value] = [:]

    init(initialValue: @escaping (Key) -> Value) {
        self.initialValue = initialValue
    }

    override func setValue(_ newValue: Value, at key: Key) {
        _value[key] = newValue
    }

    override func getValue(at key: Key) -> Value {
        if let value = _value[key] {
            return value
        }

        let newValue = initialValue(key)
        _value[key] = newValue
        return newValue
    }
}
