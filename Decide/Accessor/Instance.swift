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
@MainActor public struct Instance<State: AtomicState, Object> {

    public typealias PropertyKeyPath = KeyPath<State, DefaultInstance<Object>>

    private let instanceKeyPath: PropertyKeyPath

    public init(_ keyPath: KeyPath<State, DefaultInstance<Object>>) {
        self.instanceKeyPath = keyPath
    }

    public static subscript<EnclosingObject: EnvironmentManagedObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Object>,
        storage storageKeyPath: KeyPath<EnclosingObject, Self>
    ) -> Object {
        get {
            let storage = instance[keyPath: storageKeyPath]
            let instanceKeyPath = storage.instanceKeyPath
            let environment = instance.environment
            return environment.defaultInstance(at: instanceKeyPath).wrappedValue
        }
    }

    @available(*, unavailable, message: "@Instance must be enclosed in EnvironmentManagedObject.")
    public var wrappedValue: Object {
        get { fatalError() }
    }
}

extension ApplicationEnvironment {
    func defaultInstance<State: AtomicState, Object>(
        at keyPath: KeyPath<State, DefaultInstance<Object>>
    ) -> DefaultInstance<Object> {
        let storage: State = self[State.key()]
        return storage[keyPath: keyPath]
    }
}

