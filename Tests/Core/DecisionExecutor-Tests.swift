//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
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
import SwiftUI
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


@MainActor final class StorageTests: XCTestCase {

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
        let completed: XCTestExpectation

        func execute(read: Decide.StorageReader, write: Decide.StorageWriter) -> Decide.Effect {
            let currentValue = read(Counter.self)
            let step = read(Step.self)
            let nextValue = currentValue + step
            write(nextValue, into: Counter.self)
            return NextStep(completed: completed)
        }
    }

    struct NextStep: Effect {
        let completed: XCTestExpectation

        func perform(read: StorageReader) async -> Decision {
            let goal = await read(Goal.self)
            let count = await read(Counter.self)
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
        let core = DecisionEffectStorage()
        let sut = ConsumerView()
            .decisionCore(core)

        core.execute(ConfigureCounter(initial: 0, goal: 100, step: 10), context: .here())
//        core.execute(MakeStep(completed: exp))

    }
}

struct ConsumerView: View {

    @MakeDecision var makeDecision
    @Observe(Counter.self) var counter
    @State var updates: [Counter.Value] = []

    var body: some View {
        updates.append(counter)
        return VStack {
            Text("\(counter)")
        }
    }
}
