//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
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

final class StorageKeyTests: XCTestCase {

    //===----------------------------------------------------------------------===//
    // MARK: - Equitable
    //===----------------------------------------------------------------------===//

    func test_SameType_keys_same() {
        XCTAssertEqual(
            IntStateSample.key,
            IntStateSample.key
        )
    }

    func test_DifferentType_keys_different() {
        XCTAssertNotEqual(
            IntStateSample.key,
            StringStateSample.key
        )
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Hashable
    //===----------------------------------------------------------------------===//

    func test_SameType_hashValue_same() {
        XCTAssertEqual(
            IntStateSample.key.hashValue,
            IntStateSample.key.hashValue
        )
    }

    func test_DifferentType_hashValue_different() {
        XCTAssertNotEqual(
            IntStateSample.key.hashValue,
            StringStateSample.key.hashValue
        )
    }
}

