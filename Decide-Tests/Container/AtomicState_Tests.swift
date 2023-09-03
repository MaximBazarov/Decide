//===----------------------------------------------------------------------===//
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
import XCTest
import DecideTesting
@testable import Decide

@MainActor final class AtomicState_Tests: XCTestCase {
    
    final class State: AtomicState {
        @Property var str = "str-default"
        @Mutable @Property var strMutable = "strMutable-default"
    }

    //===------------------------------------------------------------------===//
    // MARK: - Value
    //===------------------------------------------------------------------===//

    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = ApplicationEnvironment()

        sut.AssertValueAt(\State.$str, isEqual: "str-default")
        sut.AssertValueAt(\State.$strMutable, isEqual: "strMutable-default")
    }

    func test_SetValue() throws {
        let sut = ApplicationEnvironment()

        let newValue = "\(#function)-modified"
        sut.setValue(newValue, \State.$str)
        sut.setValue(newValue, \State.$strMutable)

        sut.AssertValueAt(\State.$str, isEqual: newValue)
        sut.AssertValueAt(\State.$strMutable, isEqual: newValue)
    }

    //===------------------------------------------------------------------===//
    // MARK: - Observation
    //===------------------------------------------------------------------===//

    class Tracker: EnvironmentObservingObject {
        @DefaultEnvironment var environment
        @DefaultObserve(\State.$str) var str
        @DefaultObserve(\State.$strMutable) var strMutableObserve
        @DefaultBind(\State.$strMutable) var strMutable

        var updatesCount: UInt = 0

        func didLoad() {
            // in order to subscribe to the properties this object is reading we need to call reading.
            environmentDidUpdate()
            updatesCount -= 1
        }

        func environmentDidUpdate() {
            // we need to read property in order to subscribe.
            _ = str
            _ = strMutable
            _ = strMutableObserve
            updatesCount += 1
        }
    }

    func test_Observation() async {
        let env = ApplicationEnvironment()
        let sut = WithEnvironment(env, object: Tracker())

        sut.didLoad()

        let newValue = "\(#function)-modified"
        env.setValue(newValue, \State.$str)
        env.setValue(newValue, \State.$strMutable)
        env.setValue(newValue, \State.$strMutable)

        XCTAssertEqual(sut.updatesCount, 3)
        XCTAssertEqual(sut.str, newValue)
        XCTAssertEqual(sut.strMutableObserve, newValue)
        XCTAssertEqual(sut.strMutable, newValue)
    }

    func test_Observation_BindSet() async {
        let env = ApplicationEnvironment()
        let sut = WithEnvironment(env, object: Tracker())
        let sut2 = WithEnvironment(env, object: Tracker())

        sut.didLoad()
        sut2.didLoad()

        let newValue = "\(#function)-modified"

        sut2.strMutable = newValue
        env.setValue(newValue, \State.$str)

        XCTAssertEqual(sut.updatesCount, 2)
        XCTAssertEqual(sut.strMutable, newValue)
        XCTAssertEqual(sut.str, newValue)
        XCTAssertEqual(sut.strMutableObserve, newValue)
    }

}
