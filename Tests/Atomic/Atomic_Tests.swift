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

@MainActor
final class AtomicTests: XCTestCase {


    struct TestInt1: AtomicState {
        static func defaultValue() -> Int { 0 }
    }

    struct TestInt2: AtomicState {
        static func defaultValue() -> Int { 0 }
    }

    func testKeyUniqueness() {
        let key1 = TestInt1.key
        let key2 = TestInt2.key
        let key3 = TestInt1.key

        XCTAssertTrue(key1 != key2)
        XCTAssertTrue(key1 == key3)
    }
}
