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

import Foundation
@testable import Decide

@MainActor final class StateManagementTests: XCTestCase {
    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = StateEnvironment()
        let state = sut[StateUnderTest.self]
        XCTAssertEqual(state.name, "default-value")
    }

    func test_ValueForGivenStateType_IsAlwaysTheSame() throws {
        let sut = StateEnvironment()

        var state = sut[StateUnderTest.self]
        let overridden = "overriden"

        state.name = overridden

        state = sut[StateUnderTest.self]

        XCTAssertEqual(state.name, overridden)
    }

    func test_GetProperty_ReturnsDefaultValue() {
        let sut = StateEnvironment()
        let kp = \StateUnderTest.$name

        let property = sut.getProperty(kp)

        XCTAssertEqual(property.wrappedValue, "default-value")
    }

    func test_GetProperty_UpdateValue_ReturnsUpdatedValue() {
        let sut = StateEnvironment()
        let kp = \StateUnderTest.$name

        let property = sut.getProperty(kp)
        property.wrappedValue = "newValue"

        let propertyOtherInstance = sut.getProperty(kp)
        XCTAssertEqual(propertyOtherInstance.wrappedValue, "newValue")
    }
}
