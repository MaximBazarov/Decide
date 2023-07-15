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
@testable import Decide


//===----------------------------------------------------------------------===//
// MARK: - Set state
//===----------------------------------------------------------------------===//

public extension ApplicationEnvironment {
    func set<V, S: AtomicState>(_ value: V, at propertyKeyPath: KeyPath<S, Property<V>>) {
        let property = getProperty(propertyKeyPath)
        property.wrappedValue = value
    }

    func set<V, I: Hashable, S: KeyedState<I>>(
        _ value: V,
        with identifier: I,
        at propertyKeyPath: KeyPath<S, Property<V>>
    ) {
        let property = getProperty(propertyKeyPath, at: identifier)
        property.wrappedValue = value
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Assert
//===----------------------------------------------------------------------===//
import XCTest

public extension ApplicationEnvironment {
    func Assert<V: Equatable, S: AtomicState>(
        _ propertyKeyPath: KeyPath<S, Property<V>>,
        isEqual value: V,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let stateValue = getProperty(propertyKeyPath).wrappedValue
        guard stateValue == value
        else {
            return XCTFail("\(String(describing: stateValue)) is not equal \(String(describing: value))", file: file, line: line)
        }
    }

    func Assert<V: Equatable, I: Hashable, S: KeyedState<I>>(
        _ propertyKeyPath: KeyPath<S, Property<V>>,
        at identifier: I,
        isEqual value: V,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let stateValue = getProperty(propertyKeyPath, at: identifier).wrappedValue
        guard stateValue == value
        else {
            return XCTFail("\(String(describing: stateValue)) is not equal \(String(describing: value))", file: file, line: line)
        }
    }
}
