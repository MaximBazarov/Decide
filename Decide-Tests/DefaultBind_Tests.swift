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
import DecideTesting

@testable import Decide

@MainActor final class DefaultBindTests: XCTestCase {

    class EnvironmentObservingNestedObject: EnvironmentObservingObject {
        func environmentDidUpdate() {}
        @DefaultEnvironment var environment
    }

    class EnvironmentObservingObjectUnderTest: EnvironmentObservingObject {
        @DefaultEnvironment var environment
        @DefaultBind(\StateUnderTest.$name) var put

        var updatesCount: UInt = 0

        let nestedObject = EnvironmentObservingNestedObject()

        func didLoad() {
            // in order to subscribe to the properties this object is reading we need to call reading.
            environmentDidUpdate()
        }
        
        func environmentDidUpdate() {
            _ = put // we need to read property in order to subscribe.
            updatesCount += 1
        }
    }
    
    func test_DefaultBind_WithEnvironment_OverridesEnvironment() {
        let env = ApplicationEnvironment()
        let sut = WithEnvironment(env, object: EnvironmentObservingObjectUnderTest())
        
        XCTAssert(sut.$put.environment === env,
                  "@DefaultBind environment was not overriden")
        XCTAssert(sut.nestedObject.environment === env,
                  "@DefaultBind environment was not overriden")
    }
    
    func test_Observation_DefaultBind_getNotifiedOnPropertyUpdate() {
        let env = ApplicationEnvironment()
        let sut = WithEnvironment(env, object: EnvironmentObservingObjectUnderTest())
        let property = env.getProperty(\StateUnderTest.$name)
        
        sut.didLoad()
        property.wrappedValue = "test"
        
        // One update is happening on load.
        XCTAssertEqual(sut.updatesCount, 2)
    }
}
