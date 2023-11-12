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

@propertyWrapper
@MainActor public struct Instance<Storage: AtomicStorage, Object> {

    private let instanceKeyPath: KeyPath<Storage, DefaultInstance<Object>>

    public init(_ keyPath: KeyPath<Storage, DefaultInstance<Object>>) {
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
    func defaultInstance<Storage: AtomicStorage, Object>(
        at keyPath: KeyPath<Storage, DefaultInstance<Object>>
    ) -> DefaultInstance<Object> {
        let storage: Storage = storage(Storage.key())
        return storage[keyPath: keyPath]
    }
}

