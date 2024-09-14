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

import SwiftUI
import XCTest

@testable import Decide

final class ObservableValue_Tests: XCTestCase {
    final class CounterState: SharedState {
        @ObservableValue var count = 0
    }

    // MARK: - Atomic

    @MainActor func test_GetsDefaultValue_SameValueForAll() {
        let env = SharedEnvironment()

        let state1 = env.get(CounterState.self)
        let state2 = env.get(CounterState.self)

        XCTAssertEqual(state1[keyPath: \.$count].wrappedValue, 0)
        XCTAssertEqual(state2[keyPath: \.$count].wrappedValue, 0)
    }

    @MainActor func test_GetsAssignedValue_SameValueForAll() {
        let env = SharedEnvironment()

        let state1 = env.get(CounterState.self)
        let state2 = env.get(CounterState.self)

        state1.$count.projectedValue.storage.setValue(9)
        XCTAssertEqual(state1[keyPath: \.$count].wrappedValue, 9)
        XCTAssertEqual(state2[keyPath: \.$count].wrappedValue, 9)
    }


    // MARK: - Key Value
    
    final class MultipleCountersState: SharedState {
        @ObservableKeyValue<Int, Int> var count = { key in 0 }
    }

    @MainActor func test_GetsDefaultValueAtKey_SameValueForAll() {
        let env = SharedEnvironment()

        let state1 = env.get(MultipleCountersState.self)
        let state2 = env.get(MultipleCountersState.self)

        let key = 7
        XCTAssertEqual(state1[keyPath: \.$count].wrappedValue(key), 0)
        XCTAssertEqual(state2[keyPath: \.$count].wrappedValue(key), 0)
    }

    @MainActor func test_GetsAssignedValueAtKey_SameValueForAll() {
        let env = SharedEnvironment()

        let state1 = env.get(MultipleCountersState.self)
        let state2 = env.get(MultipleCountersState.self)

        let key = 7
        state1[keyPath: \.$count].projectedValue[key] = 9

        XCTAssertEqual(state1[keyPath: \.$count].wrappedValue(key), 9)
        XCTAssertEqual(state2[keyPath: \.$count].wrappedValue(key), 9)
    }
}
