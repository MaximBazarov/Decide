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
import Combine

@testable import Decide

@MainActor
final class EnvironmentTests: XCTestCase {

    var sut: Environment!

    override func setUp() {
        sut = Environment()
    }

    override func tearDown() {
        sut = nil
    }

    struct TestDecision: Decision {
        func execute(read: StorageReader, write: StorageWriter) -> Effect {
            TestEffect()
        }
    }

    struct TestEffect: Effect {
        func perform() async -> Decision {
            TestEffect().asDecision
        }
    }

    func testEffects() async {
        sut.execute(TestDecision(), context: .here())
        await waitOutside(milliseconds: 1)
        print("DONE.")
    }
}


actor OutsideWaiter {
    var finish: Date = .now

    func wait(deadline: TimeInterval) async {
        let sleepDuration = Duration.milliseconds(1)
        finish = .now.advanced(by: deadline)
        while Date.now < finish {
            try? await Task.sleep(for: sleepDuration)
        }
    }
}


/// Waits outside of `MainActor` a given amount of milliseconds.
func waitOutside(milliseconds: Int) async {
    await OutsideWaiter().wait(
        deadline: TimeInterval(Double(milliseconds) / 1000)
    )
}
