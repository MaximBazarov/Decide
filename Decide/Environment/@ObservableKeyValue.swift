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

@propertyWrapper
@MainActor
public final class ObservableKeyValue<Key: Hashable, Value> {
    public var wrappedValue: (Key) -> Value { storage.getValue }
    public var projectedValue: ObservableKeyValue<Key, Value> { self }

    var storage: KeyValueStorage<Key, Value>

    public init(wrappedValue: @escaping (Key) -> Value) {
        self.storage = LazyKeyValueStorage<Key, Value>(initialValue: wrappedValue)
    }

    subscript(_ key: Key) -> Value {
        get { storage.getValue(at: key) }
        set { storage.setValue(newValue, at: key) }
    }
}
