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
final class ObservationSystemTests: XCTestCase {
    func testSubscribe() {
        let observationSystem = ObservationSystem()
        let key = StorageKey(uri: "testKey")
        let observableValue = ObservableValue(context: .here())

        observationSystem.subscribe(observableValue, to: key)

        let observations = observationSystem.storage.storage[key]
        XCTAssertNotNil(observations)
        XCTAssertTrue(
            observations?.count == 1,
            "There should be one observation for the key.")
        XCTAssertTrue(
            observations?.first?.ref === observableValue,
            "The observation should be equal to the observableValue.")
    }

    func testPopSingleKey() {
        let observationSystem = ObservationSystem()
        let key = StorageKey(uri: "testKey")
        let observableValue1 = ObservableValue(context: .here())
        let observableValue2 = ObservableValue(context: .here())

        observationSystem.subscribe(observableValue1, to: key)
        observationSystem.subscribe(observableValue2, to: key)

        let poppedObservations = observationSystem.pop(observationsOf: key)

        XCTAssertTrue(
            poppedObservations.count == 2,
            "There should be two observations for the key.")
        XCTAssertTrue(
            poppedObservations.contains(observableValue1),
            "The poppedObservations should contain observableValue1.")
        XCTAssertTrue(
            poppedObservations.contains(observableValue2),
            "The poppedObservations should contain observableValue2.")

        let remainingObservations = observationSystem.storage.storage[key]
        XCTAssertNil(remainingObservations)
    }

    func testPopMultipleKeys() {
        let observationSystem = ObservationSystem()
        let key1 = StorageKey(uri: "testKey1")
        let key2 = StorageKey(uri: "testKey2")
        let observableValue1 = ObservableValue(context: .here())
        let observableValue2 = ObservableValue(context: .here())

        observationSystem.subscribe(observableValue1, to: key1)
        observationSystem.subscribe(observableValue2, to: key2)

        let poppedObservations = observationSystem.storage.pop(observationsOf: Set([key1, key2]))

        XCTAssertTrue(
            poppedObservations.count == 2,
            "There should be two observations for the multiple keys.")
        XCTAssertTrue(
            poppedObservations.contains(observableValue1),
            "The poppedObservations should contain observableValue1.")
        XCTAssertTrue(
            poppedObservations.contains(observableValue2),
            "The poppedObservations should contain observableValue2.")

        let remainingObservationsForKey1 = observationSystem.storage.storage[key1]
        let remainingObservationsForKey2 = observationSystem.storage.storage[key2]

        XCTAssertNil(remainingObservationsForKey1)
        XCTAssertNil(remainingObservationsForKey2)
    }

    func testSinglePassObservation() {
        let observationSystem = ObservationSystem()
        let key = StorageKey(uri: "testKey")
        let observableValue = ObservableValue(context: .here())

        observationSystem.subscribe(observableValue, to: key)
        _ = observationSystem.pop(observationsOf: key)
        let poppedObservations = observationSystem.pop(observationsOf: key)

        XCTAssertTrue(
            poppedObservations.isEmpty,
            "Single pass observation should be removed after the first notification."
        )
    }

    func testWillChangeValue() {
        let observationSystem = ObservationSystem()
        let key = StorageKey(uri: "testKey")
        let observableValue = ObservableValue(context: .here())

        var valueChanged = false
        let unsubscribe = observableValue.objectWillChange.sink { _ in
            valueChanged = true
        }

        observationSystem.subscribe(observableValue, to: key)
        observableValue.valueWillChange()

        XCTAssertTrue(
            valueChanged,
            "willChangeValue should trigger the observation.")
        unsubscribe.cancel()
    }
}
