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

    enum Goal: AtomicState {
        static func defaultValue() -> Int { 0 }
    }

    enum Counter: AtomicState {
        static func defaultValue() -> Int { 0 }
    }

    enum Step: AtomicState {
        static func defaultValue() -> Int { 1 }
    }

    struct ConfigureCounter: Decision {
        let initial: Int
        let goal: Int
        let step: Int

        func execute(read: StorageReader, write: StorageWriter) -> Decide.Effect {
            let x = read(IntStateSample.self)
            write(x+1, into: IntStateSample.self)
            write(goal, into: Goal.self)
            write(step, into: Step.self)
            return noEffect
        }
    }

    struct MakeStep: Decision {
        func execute(read: Decide.StorageReader, write: Decide.StorageWriter) -> Decide.Effect {
            let currentValue = read(Counter.self)
            let step = read(Step.self)
            let nextValue = currentValue + step
            write(nextValue, into: Counter.self)
            return NextStep()
        }
    }

    struct NextStep: Effect {
        func perform(read: StorageReader) async -> Decision {
            let counter = await read(Counter.self)
            let goal = await read(Goal.self)
            guard counter < goal else { return noDecision }
            return await MakeStep()
        }
    }

    func test_Counter_goal100_step20__ShouldExecute5times__resultMustBe100() async {
        let sut = DecisionCore()
        let read = sut.reader()

        sut.execute(
            ConfigureCounter(
                initial: 0,
                goal: 100,
                step: 10
            )
        )

        sut.execute(MakeStep())

        await async_sleep(ms: 10)

        XCTAssertEqual(read(Counter.self), 100)

    }
}
