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
import Combine
@testable import Decide

@MainActor final class ObservationSystemTests: XCTestCase {

    func test_Subscribe_mustAdd_Publisher() {
        let sut = ObservationSystem()
        let publisher = ObservableAtomicValue()
        sut.subscribe(publisher, for: IntStateSample.key)

        XCTAssert(sut.observations[IntStateSample.key]?.count == 1)
        let storedPublisher = sut
            .observations[IntStateSample.key]!
            .first!
            .value!

        XCTAssert(id(storedPublisher) == id(publisher))
    }

    func test_Subscribe_TwoPublishersSameKey_mustAdd_BothPublishers() {
        let sut = ObservationSystem()
        let publisher1 = ObservableAtomicValue()
        let publisher2 = ObservableAtomicValue()

        sut.subscribe(publisher1, for: IntStateSample.key)
        sut.subscribe(publisher2, for: IntStateSample.key)

        XCTAssert(sut.observations[IntStateSample.key]?.count == 2)
        let keyObservations = sut.observations[IntStateSample.key]!

        XCTAssertTrue(
            keyObservations.contains { ref in
                id(ref.value) == id(publisher1)
            }
        )
        XCTAssertTrue(
            keyObservations.contains { ref in
                id(ref.value) == id(publisher2)
            }
        )
    }

    func test_Notify_mustRemove_AllPublishersOfKey() {
        let sut = ObservationSystem()
        let publisher1 = ObservableAtomicValue()
        let publisher2 = ObservableAtomicValue()

        sut.subscribe(publisher1, for: IntStateSample.key)
        sut.subscribe(publisher2, for: IntStateSample.key)
        
        sut.didChangeValue(for: Set([IntStateSample.key]))

        XCTAssertFalse(sut.observations.keys.contains(IntStateSample.key))
        XCTAssertTrue(sut.observations.keys.count == 0)
    }

    func test_TwoKeys_mustRemove_publishersOfKey_mustKeep_publisherOfOtherKey() {
        let sut = ObservationSystem()

        let publisherKeep = ObservableAtomicValue()
        let publisherRemove = ObservableAtomicValue()

        sut.subscribe(publisherKeep, for: StringStateSample.key)
        sut.subscribe(publisherRemove, for: IntStateSample.key)

        sut.didChangeValue(for: Set([IntStateSample.key]))

        XCTAssertFalse(sut.observations.keys.contains(IntStateSample.key))
        XCTAssertTrue(sut.observations.keys.contains(StringStateSample.key))

        XCTAssertTrue(sut.observations.keys.count == 1)
    }
}
