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
    func setValue<State: AtomicState, Value>(
        _ newValue: Value,
        _ keyPath: KeyPath<State, Mutable<Value>>
    ) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue))
        telemetry.log(event: TestingMutation(context: .init(), keyPath: "\(keyPath)", value: newValue))
    }

    /// Set value at ``Mutable`` KeyPath on ``AtomicState``.
    func setValue<Identifier: Hashable, State: KeyedState<Identifier>, Value>(
        _ newValue: Value,
        _ keyPath: KeyPath<State, Mutable<Value>>,
        at identifier: Identifier
    ) {
        setValue(newValue, keyPath.appending(path: \.wrappedValue), at: identifier)
        telemetry.log(event: TestingMutation(context: .init(), keyPath: "\(keyPath):\(identifier)", value: newValue))
    }
}


final class TestingMutation<Value>: TelemetryEvent {
    let category: String = "Testing: State Mutation"
    let name: String = "Property updated:"
    let logLevel: OSLogType = .debug
    let context: Decide.Context

    let keyPath: String
    let value: Value

    init(context: Decide.Context, keyPath: String, value: Value) {
        self.keyPath = keyPath
        self.context = context
        self.value = value
    }

    func message() -> String {
        "\(keyPath) -> \(String(reflecting: value))"
    }
}
