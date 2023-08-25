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
import OSLog

public extension ApplicationEnvironment {
    /// Set value at ``Mutable`` KeyPath on ``AtomicState``.
    func setValue<S: AtomicState, Value>(_ newValue: Value, _ keyPath: KeyPath<S, Mutable<Value>>) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue))
        telemetry.log(event: TestingMutation(context: .init(), keyPath: "\(keyPath)", value: newValue))
    }

    /// Set value at ``Mutable`` KeyPath on ``AtomicState``.
    func setValue<I:Hashable, S: KeyedState<I>, Value>(
        _ newValue: Value,
        _ keyPath: KeyPath<S, Mutable<Value>>,
        at identifier: I
    ) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue), at: identifier)
        telemetry.log(event: TestingMutation(context: .init(), keyPath: "\(keyPath):\(identifier)", value: newValue))
    }
}


final class TestingMutation<V>: TelemetryEvent {
    let category: String = "Testing: State Mutation"
    let name: String = "Property updated:"
    let logLevel: OSLogType = .debug
    let context: Decide.Context

    let keyPath: String
    let value: V

    init(context: Decide.Context, keyPath: String, value: V) {
        self.keyPath = keyPath
        self.context = context
        self.value = value
    }

    func message() -> String {
        "\(keyPath) -> \(String(reflecting: value))"
    }
}
