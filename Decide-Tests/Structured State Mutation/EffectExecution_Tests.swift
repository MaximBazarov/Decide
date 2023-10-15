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

    struct MustupdateState: Decision {
        let id: UUID
        
        func mutate(_ env: DecisionEnvironment) {
            env[\AppUnderTest.$selectedItemID] = id
            env.perform(effect: AppUnderTest.Editor.FetchListOfItems())
        }
    }

    func test_MakeDecision() async throws {
        let sut = ApplicationEnvironment()

        // TODO: Make awaiting method in Decide Testing
        await sut.makeAwaiting(decision: AppUnderTest.Editor.MustFetchList(), context: Context(file: #file, line: #line))

        sut.Assert(\AppUnderTest.$itemList) { items in
            items.count == 1
        }
    }
}

