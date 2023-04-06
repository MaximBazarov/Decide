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
final class DecisionTests: XCTestCase {

    struct TestDecision: Decision {
        func execute(read: StorageReader, write: StorageWriter) -> Effect {
            noEffect
        }
    }

    struct TestEffect: Effect {
        func perform() async -> Decision {
            noDecision
        }
    }

    func testAsEffect() async {
        let sut = TestDecision()
        let effect = sut.asEffect
        let decision = await effect.perform()

        XCTAssertTrue(decision is TestDecision)
    }

    let reader = StorageReader(storage: KeyValueStorage(), context: .here())
    let writer = StorageWriter(storage: KeyValueStorage(), context: .here())

    func testEffectAsDecision() {
        let sut = TestEffect()
        let decision = sut.asDecision
        let effect = decision.execute(read: reader, write: writer)

        XCTAssertTrue(effect is TestEffect)
    }

    func testNoOp() {
        let decision1: Effect = noEffect
        let decision2: Decision = noDecision
        
        XCTAssertTrue(decision1.isNoOp)
        XCTAssertTrue(decision2.isNoOp)
    }
}

