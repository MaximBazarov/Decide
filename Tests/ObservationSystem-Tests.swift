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
        let publisher = ObservableObjectPublisher()
        sut.subscribe(publisher: publisher, for: intStateKey)

        XCTAssert(sut.observations[intStateKey]?.count == 1)
        let storedPublisher: ObservableObjectPublisher = sut
            .observations[intStateKey]!
            .first!
            .value!

        XCTAssert(id(storedPublisher) == id(publisher))
    }

    func test_Subscribe_TwoPublishersSameKey_mustAdd_BothPublishers() {
        let sut = ObservationSystem()
        let publisher1 = ObservableObjectPublisher()
        let publisher2 = ObservableObjectPublisher()

        sut.subscribe(publisher: publisher1, for: intStateKey)
        sut.subscribe(publisher: publisher2, for: intStateKey)

        XCTAssert(sut.observations[intStateKey]?.count == 2)
        let keyObservations = sut.observations[intStateKey]!

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
        let publisher1 = ObservableObjectPublisher()
        let publisher2 = ObservableObjectPublisher()

        sut.subscribe(publisher: publisher1, for: intStateKey)
        sut.subscribe(publisher: publisher2, for: intStateKey)
        sut.didChangeValue(for: Set([intStateKey]))

        XCTAssertFalse(sut.observations.keys.contains(intStateKey))
        XCTAssertTrue(sut.observations.keys.count == 0)
    }

    func test_TwoKeys_mustRemove_publishersOfKey_mustKeep_publisherOfOtherKey() {
        let sut = ObservationSystem()

        let publisherKeep = ObservableObjectPublisher()
        let publisherRemove = ObservableObjectPublisher()

        sut.subscribe(publisher: publisherKeep, for: stringStateKey)
        sut.subscribe(publisher: publisherRemove, for: intStateKey)

        sut.didChangeValue(for: Set([intStateKey]))

        XCTAssertFalse(sut.observations.keys.contains(intStateKey))
        XCTAssertTrue(sut.observations.keys.contains(stringStateKey))

        XCTAssertTrue(sut.observations.keys.count == 1)
    }
}
