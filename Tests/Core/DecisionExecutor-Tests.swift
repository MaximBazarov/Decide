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
            let goal = await read(Goal.self)
            let count = await read(Counter.self)
            guard count < goal else { return noDecision }
            return await MakeStep()
        }
    }

    enum CounterX10: Computation {
        static func compute(read: StorageReader) -> Int {
            read(Counter.self) * 10
        }
    }

    @Observe(CounterX10.self) var counterX10

    func test_Vanilla() {
        let step = 10
        let goal = 100
        var counter = 0
        while counter < goal {
            counter += step
        }
        XCTAssertEqual(counter, goal)
    }

    func test_DecisionExecution_Observing() {
        let core = DecisionCore()
        let sut = ConsumerUseCase(core: core)
        let read = core.reader()

        sut.render()
        core.execute(ConfigureCounter(initial: 0, goal: 100, step: 10))
        core.execute(MakeStep())
        while read(Counter.self) < read(Goal.self) {
        }

        XCTAssertEqual(read(Counter.self), 100)
    }

    func test_Observations_ProduceCorrectValueSequences() {
        let core = DecisionCore()
        let sut = ConsumerUseCase(core: core)
        let write = core.writer()
        let read = core.reader()

        sut.render()
        let i = read(IntStateSample.self)
        let s = read(StringStateSample.self)
        write("\(s), \(i)", into: StringStateSample.self)
    }
}

final class ConsumerUseCase {
    @Observe(Counter.self) var counter


    let core: DecisionExecutor
    var cancel: AnyCancellable!

    init(core: DecisionExecutor) {
        self.core = core
        _counter.core.override(with: core)
        self.cancel = _counter.objectWillChange.sink { [render] value in
            render()
        }
    }

    @MainActor func render() {
        print("RENDER: counter: \(counter)")
    }



}
