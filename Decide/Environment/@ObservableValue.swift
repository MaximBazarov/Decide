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
public final class ObservableValue<Value> {
    public var wrappedValue: Value { storage.getValue() }
    public var projectedValue: ObservableValue<Value> { self }

    var storage: ValueStorage<Value>

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.storage = LazyValueStorage(initialValue: wrappedValue)
    }
}
