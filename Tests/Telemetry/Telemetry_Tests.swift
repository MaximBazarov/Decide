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

import XCTest
@testable import Decide

final class Telemetry_Tests: XCTestCase {

    func test_Telemetry_MaximumLevelEnabledInTests() throws {
        // Telemetry for tests must be set to maximum to better analyze failing tests
        guard Telemetry.level == Telemetry.Level.debug
        else { return
            XCTFail("use `env DECIDE_TELEMETRY_ENABLED=8 swift test` to enable the debug level of telemetry.")
        }
    }

    func test_Telemetry_Environment_Nil_mustReturn_None() {
        let level = Telemetry.Level(nil)
        XCTAssertEqual(level, .none)
    }

    func test_Telemetry_Environment_0_mustReturn_None() {
        let level = Telemetry.Level("0")
        XCTAssertEqual(level, .none)
    }

    func test_Telemetry_Environment_2_mustReturn_Decisions() {
        let level = Telemetry.Level("2")
        XCTAssertEqual(level, .decisions)
    }

    func test_Telemetry_Environment_4_mustReturn_Effects() {
        let level = Telemetry.Level("4")
        XCTAssertEqual(level, .effects)
    }

    func test_Telemetry_Environment_8_mustReturn_Debug() {
        let level = Telemetry.Level("8")
        XCTAssertEqual(level, .debug)
    }

    func test_Telemetry_Environment_Invalid_mustReturn_None() {
        let level = Telemetry.Level("9")
        XCTAssertEqual(level, .none)
    }

}
