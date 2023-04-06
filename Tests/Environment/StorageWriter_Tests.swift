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
final class StorageWriterTests: XCTestCase {

    let sutKey = StorageKey(uri: "test://storage-reader")

    func testWrite() {
        let storage: Storage = KeyValueStorage()
        let sut = StorageWriter(storage: storage, context: .here())

        sut.write(7, at: sutKey)
        do {
            let value: Int = try storage.get(for: sutKey)
            XCTAssertTrue(
                value == 7,
                ""
            )
        } catch {
            XCTFail("Error thrown while reading the value")
        }
    }
}

