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

@testable import Decide

public extension ApplicationEnvironment {
    /// Set value at ``Mutable`` KeyPath on ``AtomicState``.
    func setValue<S: AtomicState, Value>(_ newValue: Value, _ keyPath: KeyPath<S, Mutable<Value>>) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue))
    }

    /// Set value at ``Mutable`` KeyPath on ``AtomicState``.
    func setValue<I:Hashable, S: KeyedState<I>, Value>(
        _ newValue: Value,
        _ keyPath: KeyPath<S, Mutable<Value>>,
        at identifier: I
    ) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue), at: identifier)
    }
}
