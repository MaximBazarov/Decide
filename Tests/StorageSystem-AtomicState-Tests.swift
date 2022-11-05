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

    //===----------------------------------------------------------------------===//
    // MARK: - Direct Storage Read/Write
    //===----------------------------------------------------------------------===//

    func test_EmptyStorage_mustThrow_NoValueInStorage() {
        let sut = InMemoryStorage()
        let key = IntStateSample.key
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
        let key = IntStateSample.key
        sut.setValue(10, for: key, onBehalf: nil)
        let result: Int? = try? sut.getValue(for: key, onBehalf: nil)
        XCTAssertEqual(10, result)
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Storage Reader
    //===----------------------------------------------------------------------===//

    func test_StorageReader_AtomicState_mustReturn_defaultValue() {
        let sut = InMemoryStorage()

        let result = sut.storageReader(IntStateSample.self)

        XCTAssertEqual(intDefaultValue, result)
    }

    func test_StorageReader_AtomicState_WrittenValue_mustReturn_writtenValue() {
        let sut = InMemoryStorage()

        sut.storageWriter(10, into: IntStateSample.self)
        let result = sut.storageReader(IntStateSample.self)

        XCTAssertEqual(10, result)
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Observe/Bind
    //===----------------------------------------------------------------------===//

    func test_Wrappers_AtomicState_mustReturn_defaultValue() {
        let sut = Consumer()
        XCTAssertEqual(intDefaultValue, sut.observe)
        XCTAssertEqual(intDefaultValue, sut.bind)
    }

    func test_Observe_AtomicState_WrittenValue_mustReturn_writtenValue() {
        let sut = Consumer()

        sut.writeStateValue(11)

        XCTAssertEqual(11, sut.observe)
        XCTAssertEqual(11, sut.bind)
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Storage Injection Tests
    //===----------------------------------------------------------------------===//

    func test_Observe_Storage_Override_mustHave_LocalStorage() {
        @Observe(IntStateSample.self) var sut;
        @Observe(IntStateSample.self) var global;

        let storage = InMemoryStorage()
        _sut.storage.override(with: storage)

        let writeGlobal = StorageWriter(storage: _global.storage.instance)
        let writeLocal = StorageWriter(storage: storage)

        let key = IntStateSample.key

        writeGlobal.write(12, for: key, onBehalf: key)
        writeLocal.write(10, for: key, onBehalf: key)

        XCTAssertEqual(10, sut)
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Consumer
    //===----------------------------------------------------------------------===//

    final class Consumer {
        @Bind(IntStateSample.self) var bind
        @Observe(IntStateSample.self) var observe

        let storage = InMemoryStorage()

        init() {
            _bind.storage.override(with: storage)
            _observe.storage.override(with: storage)
        }

        func writeStateValue(_ value: Int) {
            bind = value
        }
    }
}
