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

final class Environment_Tests: XCTestCase {
    final class CounterState: SharedState {
        @ObservableValue var count = 0
    }

    final class ProfileState: SharedState {
        @ObservableValue var name = "No Name"
        @ObservableValue var age = 0
    }

    @MainActor func test_EveryoneGetsTheSameInstanceOfState() {
        let env = SharedEnvironment()
        
        let state1 = env.get(CounterState.self)
        let state2 = env.get(CounterState.self)

        XCTAssertEqual(ObjectIdentifier(state1), ObjectIdentifier(state2))
    }

    @MainActor func test_StateIsNotInTheStorageIfNotUsed() {
        let env = SharedEnvironment()
        
        let _ = env.get(CounterState.self)
        XCTAssertEqual(env.warehouse.count, 1)
        // check if there's no leak into the default storage.
        XCTAssertEqual(SharedEnvironment.default.warehouse.count, 0)

        let _ = env.get(ProfileState.self)
        XCTAssertEqual(env.warehouse.count, 2)
        // check if there's no leak into the default storage.
        XCTAssertEqual(SharedEnvironment.default.warehouse.count, 0)
    }

}

