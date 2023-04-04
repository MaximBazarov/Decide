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

@MainActor
final class KeyValueStorageTests: XCTestCase {
    var storage: KeyValueStorage!

    override func setUp() {
        super.setUp()
        storage = KeyValueStorage()
    }

    override func tearDown() {
        storage = nil
        super.tearDown()
    }

    func testGetAndSet() {
        let key1 = StorageKey(type: String.self)
        let key2 = StorageKey(type: Int.self)

        do {
            let value: String = try self.storage.get(for: key1)
            XCTFail("returned \(value) while should throw error.")
        } catch {
            XCTAssertTrue(error is NoValueInStorage)
        }

        storage.set(value: "Hello", for: key1)
        storage.set(value: 42, for: key2)

        XCTAssertEqual(try storage.get(for: key1), "Hello")
        XCTAssertEqual(try storage.get(for: key2), 42)
    }

    func testOnValueUpdate() {
        let key1 = StorageKey(type: String.self)
        let key2 = StorageKey(type: Int.self)

        var updatedKeys: Set<StorageKey> = []
        storage.onValueUpdate = { keys in
            updatedKeys = keys
        }

        storage.set(value: "Hello", for: key1)
        XCTAssertEqual(updatedKeys, [key1])

        storage.set(value: 42, for: key2)
        XCTAssertEqual(updatedKeys, [key2])
    }
}
