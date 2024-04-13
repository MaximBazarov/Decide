// StorageProtocol.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

/// `AtomicValueStorage` is a protocol that represents a storage for atomic values.
/// It defines an associated type `Value` and a `wrappedValue` property that takes a `SharedEnvironment` and returns a `Value`.
@MainActor public protocol AtomicValueStorage {
    associatedtype Value
    var wrappedValue: (SharedEnvironment) -> Value { get }
}

/// `KeyValueStorage` is a protocol that represents a key-value storage.
/// It defines two associated types: `Key` and `Value`, and a `defaultValue` property that takes a `SharedEnvironment` and a `Key`, and returns a `Value`.
@MainActor public protocol KeyValueStorage {
    associatedtype Value
    associatedtype Key
    var defaultValue: (SharedEnvironment, Key) -> Value { get }
}

/// `StorageNamespace` is a protocol that represents a storage namespace.
/// It is used to separate different storage types according to their purpose.
/// For example, you can create a `UserAccount` class that conforms to `StorageNamespace`
/// to separate user account related states, decisions and effects.
/// 
/// Each `StorageNamespace` conforming type must be able to be initialized without any parameters.
@MainActor public protocol StorageNamespace: AnyObject {
    init()
}

public extension StorageNamespace {
  func storage<Storage: AtomicValueStorage>(keyPath: KeyPath<Self, Storage>) -> Storage {
    self[keyPath: keyPath]
  }
}