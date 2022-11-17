//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import XCTest
import Decide

@MainActor final class DecisionExecutorTests: XCTestCase {

    struct TestDecision: Decision {
        let value: Int
        init(_ value: Int) { self.value = value }

        func execute(read: Decide.StorageReader, write: Decide.StorageWriter) -> Decide.Effect {
            write(value, into: IntStateSample.self)
            return noEffect
        }
    }

    func test_Execute_Decision_StateChangesAccordingly() {
        let sut = DecisionCore()
        let read = sut.reader()

        sut.execute(TestDecision(77))

        XCTAssertEqual(read(IntStateSample.self), 77)

    }
}
