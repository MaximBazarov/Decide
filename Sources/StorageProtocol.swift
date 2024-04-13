// StorageProtocol.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

public protocol AtomicValueStorage {
    associatedtype Value
    var wrappedValue: (SharedEnvironment) -> Value { get }
}

/// A protocol that represents a key-value storage.
public protocol KeyValueStorage {
    associatedtype Value
    associatedtype Key
    var defaultValue: (SharedEnvironment, Key) -> Value { get }
}

/// A Protocol that represents a storage namespace.
/// It is used to separate different storage types according to their purpose.
/// Usage:
/// ```swift
/// final class UserAccount: StorageNamespace {}
/// ```
public protocol StorageNamespace: AnyObject {
    init()
}

public extension StorageNamespace {
    init() { self.init() }
}
