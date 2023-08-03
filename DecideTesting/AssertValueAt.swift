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
    func AssertValueIn<V: Equatable>(
        _ valueA: V,
        isEqual valueB: V,
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
        P: PropertyModifier,
        V: Equatable,
        S: AtomicState
    > (
        _ keyPath: KeyPath<S, P>,
        isEqual value: V,
        file: StaticString = #file,
        line: UInt = #line
    ) where P.Value == V {
        let containerValue = getValue(keyPath.appending(path: \.wrappedValue))
        AssertValueIn(containerValue, isEqual: value, file: file, line: line)
    }

    /// Asserts that value at given KeyPath is equal to given value.
    func AssertValueAt<
        V: Equatable,
        S: AtomicState
    >(
        _ keyPath: KeyPath<S, Property<V>>,
        isEqual value: V,
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
        V: Equatable,
        I: Hashable,
        S: KeyedState<I>
    >(
        _ valueA: V,
        identifier: I,
        isEqual valueB: V,
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
        P: PropertyModifier,
        V: Equatable,
        I: Hashable,
        S: KeyedState<I>
    >(
        _ keyPath: KeyPath<S, P>,
        at identifier: I,
        isEqual value: V,
        file: StaticString = #file,
        line: UInt = #line
    ) where P.Value == V {
        let containerValue = getValue(keyPath.appending(path: \.wrappedValue), at: identifier)
        AssertValueIn(containerValue, identifier: identifier, isEqual: value, file: file, line: line)
    }

    /// Asserts that value at given KeyPath and Identifier is equal to given value.
    func AssertValueAt<
        V: Equatable,
        I: Hashable,
        S: KeyedState<I>
    >(
        _ keyPath: KeyPath<S, Property<V>>,
        at identifier: I,
        isEqual value: V,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let containerValue = getValue(keyPath, at: identifier)
        AssertValueIn(containerValue, identifier: identifier, isEqual: value, file: file, line: line)
    }
}

