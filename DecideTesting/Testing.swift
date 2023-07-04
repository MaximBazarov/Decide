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

//
//public extension StateValue {
//    init(_ propertyKeyPath: KeyPath<S, Property<Value>>, env: StateEnvironment) {
//        self.init(propertyKeyPath)
//        self.environment = env
//    }
//}
//
//public extension StateBinding {
//    init(_ propertyKeyPath: KeyPath<S, Mutable<Value>>, env: StateEnvironment) {
//        self.init(propertyKeyPath)
//        self.environment = env
//    }
//}

@MainActor public func WithEnvironment<T>(_ environment: StateEnvironment, object: T) -> T {
    Mirror(reflecting: object).replaceEnvironment(with: environment)
    return object
}

private extension Mirror {

    @MainActor func replaceEnvironment(with newEnvironment: StateEnvironment) {
        for var child in children {
            replaceEnvironment(on: &child, with: newEnvironment)
        }
    }

    @MainActor func replaceEnvironment(on child: inout Mirror.Child, with newEnvironment: StateEnvironment) {
//        if let obj = child.value as? Decide.StateEnvironment {
//            obj.wrappedValue = newEnvironment
//            return
//        }
//
////        if child.value is IgnoredInMirror { return }
//
//        let m = Mirror(reflecting: child.value)
//        m.replaceEnvironment(with: newEnvironment)
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Set state
//===----------------------------------------------------------------------===//

public extension StateEnvironment {
    func set<V, S: AtomicState>(_ value: V, at propertyKeyPath: KeyPath<S, Property<V>>) {
        let property = getProperty(propertyKeyPath)
        property.wrappedValue = value
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Assert
//===----------------------------------------------------------------------===//
import XCTest

public extension StateEnvironment {
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
}
