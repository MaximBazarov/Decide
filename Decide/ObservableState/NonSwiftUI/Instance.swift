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
import SwiftUI

@propertyWrapper
@MainActor public struct Instance<S: AtomicState, O: AnyObject> {

    public typealias PropertyKeyPath = KeyPath<S, DefaultInstance<O>>

    private let propertyKeyPath: PropertyKeyPath

    public init(_ keyPath: KeyPath<S, DefaultInstance<O>>) {
        self.propertyKeyPath = keyPath
    }

    public static subscript<EnclosingObject: EnvironmentManagedObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, O>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> O {
        get {
            let storage = instance[keyPath: storageKeyPath]
            let propertyKeyPath = storage.propertyKeyPath
            let environment = instance.environment
            let property = environment.getInstance(propertyKeyPath)
            return property.wrappedValue
        }
    }

    @available(*, unavailable, message: "@Instance must be enclosed in EnvironmentManagedObject.")
    public var wrappedValue: O {
        get { fatalError() }
    }
}
