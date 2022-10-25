//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

//===----------------------------------------------------------------------===//
// MARK: - Computed State
//===----------------------------------------------------------------------===//

/// State that computes it's value based on other state's values
public protocol ComputedState {
    /// Type of the state's value
    associatedtype Value

    /// Computes the value using `Reader` function to read other states
    static func computed(read: StorageReader) -> Value

    /// Should the result of ``ComputedState/computed(read:)`` be stored in the ``StorageSystem``
    static var shouldPersistValueInStorage: Bool { get }
}

extension ComputedState {
    /// By default doesn't store the result of ``ComputedState/computed()`` in the ``StorageSystem``
    static var shouldPersistValueInStorage: Bool { false }
}

//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

public extension StorageReader {
    func callAsFunction<T: ComputedState>(_ type: T.Type) -> T.Value {
        guard type.shouldPersistValueInStorage else {
            return type.computed(read: self)
        }

        let key = StorageKey.atom(ObjectIdentifier(type))
        return read(
            key: key,
            onBehalf: key,
            defaultValue: { type.computed(read: self) }
        )
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

@MainActor public extension Observe {
    /// Read-only access to the value of the ``AtomicState``
    convenience init<T: ComputedState>(_ type: T.Type) where T.Value == Value {
        if type.shouldPersistValueInStorage {
            let key = StorageKey.atom(ObjectIdentifier(type))

            func getValue(_ reader: StorageReader) -> Value {
                do {
                    return try reader.storage.getValue(for: key, onBehalf: key)
                } catch {
                    let value = type.computed(read: reader)
                    Task {
                        reader.storage.setValue(value, for: key, onBehalf: key)
                    }
                    return value
                }
            }

            self.init(getValue: getValue)
        }

        self.init { reader in type.computed(read: reader) }
    }
}

