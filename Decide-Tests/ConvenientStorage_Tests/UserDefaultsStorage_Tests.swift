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

import SwiftUI
import XCTest

@testable import Decide

final class UserDefaultsStorage_Tests: XCTestCase {

    final class CounterState: SharedState {
        @ObservableValue var count = sampleCount
        @ObservableValue var string = sampleString
        @ObservableValue var codable = SomeCodableData.sample
        @ObservableValue var double = sampleDouble
        @ObservableValue var date = sampleDate

        static let sampleCount = 7
        static let sampleString = "seven"
        static let sampleDouble = 0.7
        static let sampleDate = Date().addingTimeInterval(7)

    }

    struct SomeCodableData: Codable {
        let int: Int
        let str: String
        let nested: NestedCodable

        static let sample = SomeCodableData(int: sampleInt, str: sampleString, nested: .sample)
        static let sampleInt = 9
        static let sampleString = "nine"

    }

    struct NestedCodable: Codable {
        let int: Int
        let double: Double
        let str: String
        let date: Date

        static let sample = NestedCodable(int: sampleInt, double: sampleDouble, str: sampleStr, date: sampleDate)
        static let sampleInt = 11
        static let sampleDouble = 0.11
        static let sampleStr = "eleven"
        static let sampleDate = Date()
    }

    @MainActor func test_EveryoneGetsTheSameInstanceOfState() {
        let env = SharedEnvironment()

        let state1 = env.get(CounterState.self)
        let state2 = env.get(CounterState.self)

        XCTAssertEqual(ObjectIdentifier(state1), ObjectIdentifier(state2))
    }
}

