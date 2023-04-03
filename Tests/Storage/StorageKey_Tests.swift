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
@testable import Decide

final class StorageKey_Tests: XCTestCase {

    func testUniqueness() {
        let key1 = StorageKey(type: Int.self)
        let key2 = StorageKey(type: Int.self)
        let key3 = StorageKey(type: String.self)
        let key4 = StorageKey(type: Int.self, additionalKeys: [1])
        let key5 = StorageKey(type: Int.self, additionalKeys: [1])
        let key6 = StorageKey(type: Int.self, additionalKeys: [2])
        let key7 = StorageKey(type: Int.self, uri: "test://unique-resource")
        let key8 = StorageKey(type: Int.self, uri: "test://unique-resource")

        XCTAssertNotEqual(key1, key3)
        XCTAssertNotEqual(key1, key4)
        XCTAssertNotEqual(key1, key7)
        XCTAssertNotEqual(key3, key4)
        XCTAssertNotEqual(key3, key7)
        XCTAssertNotEqual(key4, key6)
        XCTAssertNotEqual(key4, key7)
        XCTAssertEqual(key1, key2)
        XCTAssertEqual(key4, key5)
        XCTAssertEqual(key7, key8)
    }

    func testDebugOutput() {
        let key1 = StorageKey(type: Int.self)
        let key2 = StorageKey(type: String.self)
        let key3 = StorageKey(type: Int.self, additionalKeys: [1, "text"])
        let key4 = StorageKey(type: String.self, additionalKeys: [2, "other"], uri: "test://unique-resource")

        XCTAssertEqual(key1.debugDescription, "Int")
        XCTAssertEqual(key2.debugDescription, "String")
        XCTAssertEqual(key3.debugDescription, "Int 1, text")
        XCTAssertEqual(key4.debugDescription, "test://unique-resource (String, 2, other")
    }

}
