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

        sut.AssertValueAt(
            propertyUnderTest,
            isEqual: StateUnderTest.defaultName)
    }

    func test_ValueForGivenStateType_IsAlwaysTheSame() throws {
        let sut = ApplicationEnvironment()
        let overridden = "overriden"

        sut.setValue(overridden, propertyUnderTest)

        sut.AssertValueAt(propertyUnderTest, isEqual: overridden)
    }
}

