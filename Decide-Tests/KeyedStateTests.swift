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

@MainActor final class KeyedStateTests: XCTestCase {

    let propertyUnderTest = \KeyedStateUnderTest.$name

    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = StateEnvironment()

        sut.Assert(propertyUnderTest,
                   at: UUID(),
                   isEqual: KeyedStateUnderTest.defaultSUTName)
    }

    func test_WriteAndReadState_WithSameID() throws {
        let sut = StateEnvironment()
        let identifier = UUID()
        let value = "my-test-value"

        sut.set(value, with: identifier, at: propertyUnderTest)
        sut.Assert(propertyUnderTest,
                   at: identifier,
                   isEqual: value)

        sut.Assert(propertyUnderTest,
                   at: UUID(),
                   isEqual: KeyedStateUnderTest.defaultSUTName)
    }
}
