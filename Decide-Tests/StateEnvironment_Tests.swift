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

@MainActor final class StateManagementTests: XCTestCase {

    let propertyUnderTest = \StateUnderTest.$name

    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = ApplicationEnvironment()
        let property = sut.getProperty(\StateUnderTest.$name)

        sut.Assert(propertyUnderTest,
                   isEqual: property.defaultValue())
    }

    func test_ValueForGivenStateType_IsAlwaysTheSame() throws {
        let sut = ApplicationEnvironment()
        let overridden = "overriden"

        sut.set(overridden, at: propertyUnderTest)

        sut.Assert(propertyUnderTest, isEqual: overridden)
    }

    func test_GetProperty_UpdateValue_ReturnsUpdatedValue() {
        let sut = ApplicationEnvironment()
        let expected = "expected-value"

        let property = sut.getProperty(propertyUnderTest)
        let propertyOtherInstance = sut.getProperty(propertyUnderTest)

        property.wrappedValue = expected

        XCTAssertEqual(propertyOtherInstance.wrappedValue, expected)
        sut.Assert( propertyUnderTest, isEqual: expected)
    }
}
