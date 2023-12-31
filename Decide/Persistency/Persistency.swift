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

/**
 To implement a persistency of the value.
 Right now is just an example to prove that it's possible to wrap a value in it
 and still maintain the ``Obse``
 */
@propertyWrapper
@MainActor
public final class Persistent<Value>: ObservableValueWrapper {
    public var wrappedValue: Value { storage.value }
    public var storage: ValueStorage<Value>

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.storage = ValueStorage(initialValue: wrappedValue)
    }

    public init<Wrapper: ObservableValueWrapper>(wrappedValue: Wrapper) where Wrapper.Value == Value {
        self.storage = wrappedValue.storage
    }
}
