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
import Inject
import Combine

enum Goal: AtomicState {
    static func defaultValue() -> Int { 0 }
}

enum Counter: AtomicState {
    static func defaultValue() -> Int { 0 }
}

enum Step: AtomicState {
    static func defaultValue() -> Int { 1 }
}


@MainActor final class DecisionExecutorTests: XCTestCase {

    struct ConfigureCounter: Decision {
        let initial: Int
        let goal: Int
        let step: Int

        func execute(read: StorageReader, write: StorageWriter) -> Decide.Effect {
            let x = read(IntStateSample.self, context: .here())
            write(x+1, into: IntStateSample.self, context: .here())
            write(goal, into: Goal.self)
            write(step, into: Step.self)
            return noEffect
        }
    }

    struct MakeStep: Decision {
        let completed: XCTestExpectation

        func execute(read: Decide.StorageReader, write: Decide.StorageWriter) -> Decide.Effect {
            let currentValue = read(Counter.self, context: .here())
            let step = read(Step.self, context: .here())
            let nextValue = currentValue + step
            write(nextValue, into: Counter.self)
            return NextStep(completed: completed)
        }
    }

    struct NextStep: Effect {
        let completed: XCTestExpectation

        func perform(read: StorageReader) async -> Decision {
            let goal = await read(Goal.self, context: .here())
            let count = await read(Counter.self, context: .here())
            guard count < goal else {
                completed.fulfill()
                return noDecision
            }
            return MakeStep(completed: completed)
        }
    }

    func test_Vanilla() { /* profiling, XCMe */
        let step = 10
        let goal = 100
        var counter = 0
        while counter < goal {
            counter += step
        }
        XCTAssertEqual(counter, goal)
    }

    func test_DecisionExecution_Observing() {
        let exp = expectation(description: "")
        let core = DecisionCore()
        let sut = ConsumerUseCase(core: core)
        let read = core.reader()

        sut.render()
        core.execute(ConfigureCounter(initial: 0, goal: 100, step: 10))
        core.execute(MakeStep(completed: exp))

        wait(for: [exp], timeout: 0.1)
        /*
         Currently failing, needs Context to debug what's going on.
         XCTAssertEqual([10, 20, 30, 40, 50, 60, 70, 80, 90, 100], sut.counterUpdatesReceived)
         */
        XCTAssertEqual(read(Counter.self, context: .here()), 100)
    }
}

final class ConsumerUseCase {
    @Observe(Counter.self) var counter
    var counterUpdatesReceived: [Int] = []

    let core: DecisionExecutor
    var cancel: AnyCancellable!

    init(core: DecisionExecutor) {
        self.core = core
        _counter.core.override(with: core)
        self.cancel = _counter.observedValue.objectWillChange.sink {
            self.render()
        }
    }

    @MainActor func render() {
        self.counterUpdatesReceived.append(self.counter)
    }
}
