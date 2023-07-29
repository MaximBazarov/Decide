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

@MainActor final class DirectMutation_Tests: XCTestCase {
    
    let propertyUnderTest = \KeyedStateUnderTest.$name
    
    func test_DefaultValue_whenDidNotInitialize() throws {
        let sut = ApplicationEnvironment()
        let id = UUID()
        sut.AssertValueAt(
            propertyUnderTest,
            at: id,
            isEqual: KeyedStateUnderTest.defaultName)
    }
    
    func test_WriteAndReadState_WithSameID() throws {
        let sut = ApplicationEnvironment()
        let identifier = UUID()
        let value = "my-test-value"
        
        sut.setValue(value, propertyUnderTest, at: identifier)
        
        sut.AssertValueAt(
            propertyUnderTest,
            at: identifier,
            isEqual: value)
        
        sut.AssertValueAt(
            propertyUnderTest,
            at: UUID(),
            isEqual: KeyedStateUnderTest.defaultName)
    }
}

