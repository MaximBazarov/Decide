//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import XCTest
@testable import Decide

@MainActor final class StorageSystemIOTests: XCTestCase {
    
    func test_EmptyStorage_mustThrow_NoValueInStorage() {
        let sut = InMemoryStorage()
        let key = StorageKey.atom(ObjectIdentifier(IntStateSample.self))
        do {
            let _: Int = try sut.getValue(for: key, onBehalf: nil)
            XCTFail("Must not return value, before it was written.")
        } catch is NoValueInStorage {
            // Expected
        } catch {
            XCTFail("Must only fail when there's no value.")
        }
    }

    func test_WrittenValue_mustReturn_writtenValue() {
        let sut = InMemoryStorage()
        let key = StorageKey.atom(ObjectIdentifier(IntStateSample.self))
        sut.setValue(10, for: key, onBehalf: nil)
        let result: Int? = try? sut.getValue(for: key, onBehalf: nil)
        XCTAssertEqual(10, result)
    }
}
