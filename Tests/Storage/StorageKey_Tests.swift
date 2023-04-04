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
import Decide

final class StorageKey_Tests: XCTestCase {

    typealias TypealiasInt = Int

    func testUniqueness() {
        let key1 = StorageKey(type: Int.self)
        // when using type alias still refers to the original type
        let key2 = StorageKey(type: TypealiasInt.self)
        let key3 = StorageKey(type: String.self)
        let key4 = StorageKey(type: Int.self, additionalKeys: [1])
        let key5 = StorageKey(type: Int.self, additionalKeys: [1])
        let key6 = StorageKey(type: Int.self, additionalKeys: [2])
        let key7 = StorageKey(uri: "test://unique-resource")
        let key8 = StorageKey(uri: "test://unique-resource")

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
        let key4 = StorageKey(uri: "test://unique-resource")

        XCTAssertEqual(key1.debugDescription, "Int")
        XCTAssertEqual(key2.debugDescription, "String")
        XCTAssertEqual(key3.debugDescription, "Int, 1, text")
        XCTAssertEqual(key4.debugDescription, "test://unique-resource")
    }

    func testEquality() {
        let key1 = StorageKey(type: String.self)
        let key2 = StorageKey(type: String.self)
        let key3 = StorageKey(type: Int.self)
        let key4 = StorageKey(type: String.self, additionalKeys: ["key1"])
        let key5 = StorageKey(type: String.self, additionalKeys: ["key1"])
        let key6 = StorageKey(type: String.self, additionalKeys: ["key2"])
        let key7 = StorageKey(uri: "uniqueURI")
        let key8 = StorageKey(uri: "uniqueURI")
        let key9 = StorageKey(uri: "differentURI")

        XCTAssertNotEqual(key1, key3)
        XCTAssertNotEqual(key1, key4)
        XCTAssertNotEqual(key4, key6)
        XCTAssertNotEqual(key1, key7)
        XCTAssertNotEqual(key7, key9)

        XCTAssertEqual(key1, key2)
        XCTAssertEqual(key4, key5)
        XCTAssertEqual(key7, key8)
    }

    func testHashing() {
        let key1 = StorageKey(type: String.self)
        let key2 = StorageKey(type: String.self)
        let key3 = StorageKey(type: Int.self)
        let key4 = StorageKey(type: String.self, additionalKeys: ["key1"])
        let key5 = StorageKey(type: String.self, additionalKeys: ["key1"])
        let key6 = StorageKey(type: String.self, additionalKeys: ["key2"])
        let key7 = StorageKey(uri: "uniqueURI")
        let key8 = StorageKey(uri: "uniqueURI")
        let key9 = StorageKey(uri: "differentURI")


        XCTAssertNotEqual(key1.hashValue, key3.hashValue)
        XCTAssertNotEqual(key1.hashValue, key4.hashValue)
        XCTAssertNotEqual(key4.hashValue, key6.hashValue)
        XCTAssertNotEqual(key1.hashValue, key7.hashValue)
        XCTAssertNotEqual(key7.hashValue, key9.hashValue)

        XCTAssertEqual(key1.hashValue, key2.hashValue)
        XCTAssertEqual(key4.hashValue, key5.hashValue)
        XCTAssertEqual(key7.hashValue, key8.hashValue)
    }

}
