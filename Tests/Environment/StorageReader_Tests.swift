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
final class StorageReaderTests: XCTestCase {

    let sutKey = StorageKey(uri: "test://storage-reader")

    func testRead() {
        let storage: Storage = KeyValueStorage()
        let sut = StorageReader(storage: storage, context: .here())

        storage.set(value: 7, for: sutKey)

        do {
            let value: Int = try sut.read(sutKey)
            XCTAssertTrue(
                value == 7,
                ""
            )
        } catch {
            XCTFail("Error thrown while reading the value")
        }
    }
}

