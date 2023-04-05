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

import Foundation
import XCTest
@testable import Decide

@MainActor
final class ObservableValueStorageTests: XCTestCase {

    func testPop_ObservationsOfKey() {
        let storage = ObservableValueStorage()
        let key = StorageKey(uri: "test-key")
        let observableValue = ObservableValue(context: .here())

        storage.add(observableValue, for: key)

        let poppedObservations = storage.pop(observationsOf: key)

        XCTAssertTrue(
            poppedObservations.count == 1,
            "There should be one observation popped for the given key"
        )
        XCTAssertTrue(
            storage.storage[key]?.isEmpty ?? true,
            "The storage should be empty for the given key after popping"
        )
    }

    func testPop_ObservationsOfMultipleKeys() {
        let storage = ObservableValueStorage()
        let key1 = StorageKey(uri: "test-key-1")
        let key2 = StorageKey(uri: "test-key-2")
        let observableValue1 = ObservableValue(context: .here())
        let observableValue2 = ObservableValue(context: .here())

        storage.add(observableValue1, for: key1)
        storage.add(observableValue2, for: key2)

        let poppedObservations = storage.pop(observationsOf: Set([key1, key2]))

        XCTAssertTrue(
            poppedObservations.count == 2,
            "There should be two observations popped for the given keys"
        )
        XCTAssertTrue(
            storage.storage[key1]?.isEmpty ?? true,
            "The storage should be empty for key1 after popping"
        )
        XCTAssertTrue(
            storage.storage[key2]?.isEmpty ?? true,
            "The storage should be empty for key2 after popping"
        )
    }

    func testPop_NoObservationsForKey() {
        let storage = ObservableValueStorage()
        let key = StorageKey(uri: "test-key")

        let poppedObservations = storage.pop(observationsOf: key)

        XCTAssertTrue(
            poppedObservations.isEmpty,
            "There should be no observations for a key that hasn't been added"
        )
    }

    func testWeakRef_Initialization() {
        let observableValue = ObservableValue(context: .here())
        let weakRef = ObservableValueStorage.WeakRef(observableValue)

        XCTAssertNotNil(
            weakRef,
            "WeakRef should be initialized"
        )
        XCTAssertTrue(
            weakRef.ref === observableValue,
            "WeakRef should store the correct ObservableValue reference"
        )
    }

    func testWeakRef_Deallocation() {
        // Create an optional ObservableValue
        var observableValue: ObservableValue? = ObservableValue(context: .here())
        let weakRef = ObservableValueStorage.WeakRef(observableValue!)

        // Verify that the ref property is not nil
        XCTAssertNotNil(
            weakRef.ref,
            "WeakRef should have a non-nil ref property"
        )

        // Deallocate observableValue
        observableValue = nil

        // Verify that the ref property is now nil
        XCTAssertNil(
            weakRef.ref,
            "WeakRef should have a nil ref property after observableValue is deallocated"
        )
    }

    func testWeakRef_Equatable() {
        let observableValue1 = ObservableValue(context: .here())
        let observableValue2 = ObservableValue(context: .here())

        let weakRef1 = ObservableValueStorage.WeakRef(observableValue1)
        let weakRef2 = ObservableValueStorage.WeakRef(observableValue1)
        let weakRef3 = ObservableValueStorage.WeakRef(observableValue2)

        XCTAssertTrue(
            weakRef1 == weakRef2,
            "Two WeakRefs with the same ref property should be equal"
        )
        XCTAssertTrue(
            weakRef1 != weakRef3,
            "Two WeakRefs with different ref properties should not be equal"
        )
    }

    func testWeakRef_Hashable() {
        let observableValue1 = ObservableValue(context: .here())
        let observableValue2 = ObservableValue(context: .here())

        let weakRef1 = ObservableValueStorage.WeakRef(observableValue1)
        let weakRef2 = ObservableValueStorage.WeakRef(observableValue1)
        let weakRef3 = ObservableValueStorage.WeakRef(observableValue2)

        XCTAssertEqual(weakRef1.hashValue, weakRef2.hashValue, "Two WeakRefs with the same ref property should have the same hash value")
        XCTAssertNotEqual(weakRef1.hashValue, weakRef3.hashValue, "Two WeakRefs with different ref properties should not have the same hash value")
    }
}
