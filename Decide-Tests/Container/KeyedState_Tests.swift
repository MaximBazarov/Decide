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
import DecideTesting

@testable import Decide

@MainActor final class KeyedState_Tests: XCTestCase {
    
    final class State: KeyedState<Int> {
        @Property var str = "str-default"
        @Mutable @Property var strMutable = "strMutable-default"
    }

    //===------------------------------------------------------------------===//
    // MARK: - Value
    //===------------------------------------------------------------------===//

    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = ApplicationEnvironment()

        sut.AssertValueAt(\State.$str, at: 1, isEqual: "str-default")
        sut.AssertValueAt(\State.$strMutable, at: 1, isEqual: "strMutable-default")
    }

    func test_SetValue() throws {
        let sut = ApplicationEnvironment()

        let newValue = "\(#function)-modified"
        sut.setValue(newValue, \State.$str, at: 1)
        sut.setValue(newValue, \State.$strMutable, at: 1)

        sut.AssertValueAt(\State.$str, at: 1, isEqual: newValue)
        sut.AssertValueAt(\State.$strMutable, at: 1, isEqual: newValue)
    }

    //===------------------------------------------------------------------===//
    // MARK: - Observation
    //===------------------------------------------------------------------===//

    class Tracker: EnvironmentObservingObject {
        @DefaultEnvironment var environment
        @DefaultObserveKeyed(\State.$str) var str
        @DefaultObserveKeyed(\State.$strMutable) var strMutableObserve
        @DefaultBindKeyed(\State.$strMutable) var strMutable

        var updatesCount: UInt = 0

        let id: Int
        init(_ id: Int) {
            self.id = id
        }
        func didLoad() {
            // in order to subscribe to the properties this object is reading we need to call reading.
            environmentDidUpdate()
            updatesCount -= 1
        }

        func environmentDidUpdate() {
            // we need to read property in order to subscribe.
            _ = str[id]
            _ = strMutable[id]
            _ = strMutableObserve[id]
            updatesCount += 1
        }
    }

    func test_Observation() async {
        let id = #line
        let env = ApplicationEnvironment()
        let sut = WithEnvironment(env, object: Tracker(id))

        sut.didLoad()

        let newValue = "\(#function)-modified"

        env.setValue(newValue, \State.$str, at: id)
        env.setValue(newValue, \State.$strMutable, at: id)
        env.setValue(newValue, \State.$strMutable, at: id)

        XCTAssertEqual(sut.updatesCount, 3)
        XCTAssertEqual(sut.str[id], newValue)
        XCTAssertEqual(sut.strMutableObserve[id], newValue)
        XCTAssertEqual(sut.strMutable[id], newValue)
    }

    func test_Observation_BindSet() async {
        let id = #line
        let env = ApplicationEnvironment()
        let sut = WithEnvironment(env, object: Tracker(id))
        let sut2 = WithEnvironment(env, object: Tracker(id))

        sut.didLoad()
        sut2.didLoad()

        let newValue = "\(#function)-modified"

        sut2.strMutable[id] = newValue
        env.setValue(newValue, \State.$str, at: id)


        XCTAssertEqual(sut.updatesCount, 2)
        XCTAssertEqual(sut.strMutable[id], newValue)
        XCTAssertEqual(sut.str[id], newValue)
        XCTAssertEqual(sut.strMutableObserve[id], newValue)
    }
}

