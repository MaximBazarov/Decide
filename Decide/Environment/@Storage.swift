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


/// Overrides the default value storage of the ``ObservableValue`` with the provided ``ValueStorage``.
@propertyWrapper
@MainActor
public final class Storage<Value> {
    public var wrappedValue: ObservableValue<Value> { projectedValue }
    public var projectedValue: ObservableValue<Value>

    public init<S: ValueStorage<Value>>(wrappedValue: ObservableValue<Value>, storage: S) {
        self.projectedValue = wrappedValue
        wrappedValue.storage = storage
    }
}
