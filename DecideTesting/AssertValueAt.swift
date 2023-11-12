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

public extension ApplicationEnvironment {
    //===------------------------------------------------------------------===//
    // MARK: - Atomic
    //===------------------------------------------------------------------===//

    /// Asserts that value of given container is equal to given value.
    func AssertValueIn<Value: Equatable>(
        _ valueA: Value,
        isEqual valueB: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard valueA == valueB
        else { return XCTFail(
            "\(valueA) is not equal to \(valueB)"
            , file: file, line: line)
        }
    }

    func Assert<
        Value: Equatable,
        Storage: AtomicStorage
    >(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        _ assertion: (Value) -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = observableState(keyPath).wrappedValue
        guard assertion(containerValue) else {
            XCTFail(
                "\(containerValue) is not valid"
                , file: file, line: line)
            return
        }
    }
    /// Asserts that value at given KeyPath is equal to given value.
    func AssertValueAt<
        Value: Equatable,
        Storage: AtomicStorage
    >(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = observableState(keyPath).wrappedValue
        AssertValueIn(containerValue, isEqual: value, file: file, line: line)
    }

    /// Asserts that value at given KeyPath is equal to given value.
    func AssertValueAt<
        Value: Equatable,
        Storage: AtomicStorage
    >(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = observableState(keyPath.appending(path: \.wrappedValue)).wrappedValue
        AssertValueIn(containerValue, isEqual: value, file: file, line: line)
    }

    //===------------------------------------------------------------------===//
    // MARK: - Keyed
    //===------------------------------------------------------------------===//

    /// Asserts that value of given container and Identifier is equal to given value.
    func AssertValueIn<
        Value: Equatable,
        Identifier: Hashable,
        Storage: KeyedStorage<Identifier>
    >(
        _ valueA: Value,
        identifier: Identifier,
        isEqual valueB: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard valueA == valueB
        else { return XCTFail(
            "\(valueA) at \(identifier) is not equal to \(valueB)"
            , file: file, line: line)
        }
    }

    /// Asserts that value at given KeyPath and Identifier is equal to given value.
    func AssertValueAt<
        Value: Equatable,
        Identifier: Hashable,
        Storage: KeyedStorage<Identifier>
    >(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        at identifier: Identifier,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = observableState(keyPath, at: identifier).wrappedValue
        AssertValueIn(containerValue, identifier: identifier, isEqual: value, file: file, line: line)
    }

    func AssertValueAt<
        Value: Equatable,
        Identifier: Hashable,
        Storage: KeyedStorage<Identifier>
    >(
        _ keyPath: KeyPath<Storage, Mutable<Value>>,
        at identifier: Identifier,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = observableState(keyPath.appending(path: \.wrappedValue), at: identifier).wrappedValue
        AssertValueIn(containerValue, identifier: identifier, isEqual: value, file: file, line: line)
    }
}

