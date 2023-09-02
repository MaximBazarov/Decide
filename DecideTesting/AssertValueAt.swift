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


    /// Asserts that value at given KeyPath is equal to given value.
    func AssertValueAt<
        WrappedProperty: PropertyModifier,
        Value: Equatable,
        State: AtomicState
    >(
        _ keyPath: KeyPath<State, WrappedProperty>,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) where WrappedProperty.Value == Value {
        let containerValue = getValue(keyPath.appending(path: \.wrappedValue))
        AssertValueIn(containerValue, isEqual: value, file: file, line: line)
    }

    /// Asserts that value at given KeyPath is equal to given value.
    func AssertValueAt<
        Value: Equatable,
        State: AtomicState
    >(
        _ keyPath: KeyPath<State, Property<Value>>,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = getValue(keyPath)
        AssertValueIn(containerValue, isEqual: value, file: file, line: line)
    }

    //===------------------------------------------------------------------===//
    // MARK: - Keyed
    //===------------------------------------------------------------------===//

    /// Asserts that value of given container and Identifier is equal to given value.
    func AssertValueIn<
        Value: Equatable,
        Identifier: Hashable,
        State: KeyedState<Identifier>
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
        WrappedProperty: PropertyModifier,
        Value: Equatable,
        Identifier: Hashable,
        State: KeyedState<Identifier>
    >(
        _ keyPath: KeyPath<State, WrappedProperty>,
        at identifier: Identifier,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) where WrappedProperty.Value == Value {
        let containerValue = getValue(keyPath.appending(path: \.wrappedValue), at: identifier)
        AssertValueIn(containerValue, identifier: identifier, isEqual: value, file: file, line: line)
    }

    /// Asserts that value at given KeyPath and Identifier is equal to given value.
    func AssertValueAt<
        Value: Equatable,
        Identifier: Hashable,
        State: KeyedState<Identifier>
    >(
        _ keyPath: KeyPath<State, Property<Value>>,
        at identifier: Identifier,
        isEqual value: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = getValue(keyPath, at: identifier)
        AssertValueIn(containerValue, identifier: identifier, isEqual: value, file: file, line: line)
    }
}

