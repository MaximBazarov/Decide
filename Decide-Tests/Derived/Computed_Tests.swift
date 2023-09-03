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
import Decide

@MainActor final class Computed_Tests: XCTestCase {

    final class State: AtomicState {
        @Mutable @Property var a = "A"
        @Property var b = 9
        @Property var c = "C"

        @Computed<String> var comp = { env in
            "\(env[\State.$a])" +
            "-\(env[\State.$b])" +
            "-\(env[\State.$c])"
        }
    }

    final class StateKeyed: KeyedState<StateKeyed.ID> {
        typealias ID = Int
        @Mutable @Property var a = "A"
        @Property var b = 9
        @Property var c = "C"

        @ComputedKeyed<ID, String> var comp = { env, id in
            "\(env[\StateKeyed.$a, at: id])" +
            "-\(env[\StateKeyed.$b, at: id])" +
            "-\(env[\StateKeyed.$c, at: id])"
        }
    }
    
    //===------------------------------------------------------------------===//
    // MARK: - Value
    //===------------------------------------------------------------------===//

    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = ApplicationEnvironment()

        sut.AssertValueAt(\State.$comp, isEqual: "A-9-C")
    }

    func test_SetValue_OfOtherState() throws {
        let sut = ApplicationEnvironment()

        let newValue = "\(#function)-modified"
        sut.setValue(newValue, \State.$a)

        sut.AssertValueAt(\State.$comp, isEqual: "\(newValue)-9-C")
    }

    func test_Keyed_DefaultValue_whenDidNotInitialize() throws {
        let sut = ApplicationEnvironment()

        
        sut.AssertValueAt(\StateKeyed.$comp, at: 1,  isEqual: "A-9-C")
    }

    func test_Keyed_SetValue_OfOtherState() throws {
        let sut = ApplicationEnvironment()

        let id = 7
        let newValue = "\(#function)-modified-\(id)"
        sut.setValue(newValue, \StateKeyed.$a, at: id)

        sut.AssertValueAt(\StateKeyed.$comp, at: id, isEqual: "\(newValue)-9-C")
    }

    //===------------------------------------------------------------------===//
    // MARK: - Observation
    //===------------------------------------------------------------------===//

//    class Tracker: EnvironmentObservingObject {
//        @DefaultEnvironment var environment
//        @DefaultObserve(\State.$str) var str
//        @DefaultObserve(\State.$strMutable) var strMutableObserve
//        @DefaultBind(\State.$strMutable) var strMutable
//
//        var updatesCount: UInt = 0
//
//        func didLoad() {
//            // in order to subscribe to the properties this object is reading we need to call reading.
//            environmentDidUpdate()
//            updatesCount -= 1
//        }
//
//        func environmentDidUpdate() {
//            // we need to read property in order to subscribe.
//            _ = str
//            _ = strMutable
//            _ = strMutableObserve
//            updatesCount += 1
//        }
//    }

//    func test_Observation() async {
//        let env = ApplicationEnvironment()
//        let sut = WithEnvironment(env, object: Tracker())
//
//        sut.didLoad()
//
//        let newValue = "\(#function)-modified"
//        env.setValue(newValue, \State.$str)
//        env.setValue(newValue, \State.$strMutable)
//        env.setValue(newValue, \State.$strMutable)
//
//        XCTAssertEqual(sut.updatesCount, 3)
//        XCTAssertEqual(sut.str, newValue)
//        XCTAssertEqual(sut.strMutableObserve, newValue)
//        XCTAssertEqual(sut.strMutable, newValue)
//    }
//
//    func test_Observation_BindSet() async {
//        let env = ApplicationEnvironment()
//        let sut = WithEnvironment(env, object: Tracker())
//        let sut2 = WithEnvironment(env, object: Tracker())
//
//        sut.didLoad()
//        sut2.didLoad()
//
//        let newValue = "\(#function)-modified"
//
//        sut2.strMutable = newValue
//        env.setValue(newValue, \State.$str)
//
//        XCTAssertEqual(sut.updatesCount, 2)
//        XCTAssertEqual(sut.strMutable, newValue)
//        XCTAssertEqual(sut.str, newValue)
//        XCTAssertEqual(sut.strMutableObserve, newValue)
//    }

}
