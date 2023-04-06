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
final class NoOpTests: XCTestCase {

    func testEquality() {
        let decision1: Effect = noEffect
        let decision2: Decision = noDecision
        
        XCTAssertTrue(decision1.isNoOp)
        XCTAssertTrue(decision2.isNoOp)
    }
}

