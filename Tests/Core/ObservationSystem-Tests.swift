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
import Combine
@testable import Decide

@MainActor final class ObservationSystemTests: XCTestCase {

    func test_Atomic_Subscribe_mustAdd_Publisher() {
        let sut = ObservationSystem()
        let publisher = ObservableValue()
        let key = IntStateSample.key

        sut.subscribe(publisher, for: key)

        let storedPublisher = sut.storage.pop(observationsOf: key).first!

        XCTAssertEqual(storedPublisher.id, publisher.id)
    }

    func test_Atomic_Subscribe_TwoPublishers_SameKey_mustAdd_BothPublishers() {
        let sut = ObservationSystem()
        let publisher1 = ObservableValue()
        let publisher2 = ObservableValue()
        let key = IntStateSample.key

        sut.subscribe(publisher1, for: key)
        sut.subscribe(publisher2, for: key)

        let keyObservations = sut.storage.pop(observationsOf: key)

        XCTAssertTrue(keyObservations.contains(publisher1))
        XCTAssertTrue(keyObservations.contains(publisher2))
    }

    func test_Notify_mustRemove_AllPublishersOfKey() {
        let sut = ObservationSystem()
        let publisher1 = ObservableValue()
        let publisher2 = ObservableValue()

        sut.subscribe(publisher1, for: IntStateSample.key)
        sut.subscribe(publisher2, for: IntStateSample.key)

        sut.didChangeValue(for: Set([IntStateSample.key]))

        XCTAssertFalse(sut.storage.storage.keys.contains(IntStateSample.key))
        XCTAssertTrue(sut.storage.storage.keys.count == 0)
    }

    func test_TwoKeys_mustRemove_publishersOfKey_mustKeep_publisherOfOtherKey() {
        let sut = ObservationSystem()

        let publisherKeep = ObservableValue()
        let publisherRemove = ObservableValue()

        sut.subscribe(publisherKeep, for: StringStateSample.key)
        sut.subscribe(publisherRemove, for: IntStateSample.key)

        sut.didChangeValue(for: Set([IntStateSample.key]))

        XCTAssertFalse(sut.storage.storage.keys.contains(IntStateSample.key))
        XCTAssertTrue(sut.storage.storage.keys.contains(StringStateSample.key))

        XCTAssertTrue(sut.storage.storage.keys.count == 1)
    }
}
