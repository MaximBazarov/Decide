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
            let _: Int = try sut.getValue(for: key, onBehalf: nil, context: .here())
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
        sut.setValue(10, for: key, onBehalf: nil, context: .here())
        let result: Int? = try? sut.getValue(for: key, onBehalf: nil, context: .here())
        XCTAssertEqual(10, result)
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Storage Reader
    //===----------------------------------------------------------------------===//

    func test_StorageReader_AtomicState_mustReturn_defaultValue() {
        let storage = InMemoryStorage()
        let dependencies = DependencyGraph()        
        let sut = DecisionCore(storage: storage, dependencies: dependencies)

        let read = sut.reader()

        let result = read(IntStateSample.self)

        XCTAssertEqual(intDefaultValue, result)
    }

    func test_StorageReader_AtomicState_WrittenValue_mustReturn_writtenValue() {
        let sut = InMemoryStorage()

        sut.setValue(10, for: IntStateSample.key, onBehalf: nil, context: .here())
        let result: Int? = try? sut.getValue(for: IntStateSample.key, onBehalf: nil, context: .here())

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
    // MARK: - Consumer
    //===----------------------------------------------------------------------===//

    final class Consumer {
        @Bind(IntStateSample.self) var bind
        @Observe(IntStateSample.self) var observe

        let storage = InMemoryStorage()
        let dependencies = DependencyGraph()

        lazy var core: DecisionExecutor = DecisionCore(storage: storage, dependencies: dependencies)

        init() {
            _bind.core.override(with: core)
            _observe.core.override(with: core)
        }

        func writeStateValue(_ value: Int) {
            bind = value
        }
    }
}
