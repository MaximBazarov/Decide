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
import SwiftUI
import XCTest

@testable import Decide

final class UserDefaultsStorage_Tests: XCTestCase {
    static let testUDCounterKey = "com.decide.test.userdefaults.counter"
    static let testUDStringKey = "com.decide.test.userdefaults.string"

    final class CounterState: SharedState {

        @Storage(userDefaults: testUDCounterKey)
        @ObservableValue
        var count = sampleCount

        @Storage(userDefaults: testUDStringKey)
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
        let expected = 11

        UserDefaults.standard.set(expected, forKey: Self.testUDCounterKey)
        let controlValue = UserDefaults.standard.value(forKey: Self.testUDCounterKey) as? Int
        // Control that value is written in the User Defaults
        XCTAssertEqual(controlValue, expected)

        let state1 = env.get(CounterState.self).$count.wrappedValue
        let state2 = env.get(CounterState.self).$count.wrappedValue

        // should not use the default value if it's already in the UserDefaults
        XCTAssertNotEqual(state1, CounterState.sampleCount)
        XCTAssertNotEqual(state2, CounterState.sampleCount)

        // Must provide the UserDefaults value
        XCTAssertEqual(state1, expected)
        XCTAssertEqual(state2, expected)
    }

    @MainActor func test_DefaultValueIsWrittenInUserDefaults() {
        let env = SharedEnvironment()
        let key = Self.testUDStringKey
        let expected = Self.CounterState.sampleString

        UserDefaults.standard.removeObject(forKey: key)
        let controlValue = UserDefaults.standard.value(forKey: key)
        // Control that value is removed.
        XCTAssertNil(controlValue)

        // reading values
        let state1 = env.get(CounterState.self).$string.wrappedValue
        let state2 = env.get(CounterState.self).$string.wrappedValue
        
        // should not use the default value if it's already in the UserDefaults
        XCTAssertEqual(state1, expected)
        XCTAssertEqual(state2, expected)

        // User Defaults must hold the expected value
        let udValue = UserDefaults.standard.value(forKey: key) as? String
        XCTAssertEqual(udValue, expected)
    }
}

