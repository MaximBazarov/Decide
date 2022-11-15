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

import Inject

//===----------------------------------------------------------------------===//
// MARK: - Atomic State
//===----------------------------------------------------------------------===//

/// Value that exist only once per ``StorageSystem``
public protocol AtomicState {
    /// Type of the state's value.
    associatedtype Value

    /// Default value for the state, used if read before write.
    static func defaultValue() -> Value
}

//===----------------------------------------------------------------------===//
// MARK: - Writer
//===----------------------------------------------------------------------===//
extension AtomicState {
    static var key: StorageKey {
        StorageKey(type: Self.self, additionalKeys: [])
    }
}

public extension StorageWriter {
    func callAsFunction<T: AtomicState>(_ value: T.Value, into type: T.Type) {
        write(value, for: type.key, onBehalf: type.key)
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

public extension StorageReader {
    func callAsFunction<T: AtomicState>(_ type: T.Type) -> T.Value {
        return read(
            key: type.key,
            onBehalf: type.key,
            fallbackValue: type.defaultValue,
            shouldStoreDefaultValue: true
        )
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

@MainActor public extension Observe {
    /// Read-only access to the value of the ``AtomicState``
    convenience init<T: AtomicState>(_ type: T.Type) where T.Value == Value {
        self.init(key: T.key, getValue: { reader in
            reader(type)
        })
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Bind
//===----------------------------------------------------------------------===//

@MainActor public extension Bind {
    /// Read/write access to the value of the ``AtomicState``
    convenience init<T: AtomicState>(_ state: T.Type) where T.Value == Value {
        self.init(
            getValue: { read in read(state) },
            setValue: { write, value in write(value, into: state) }
        )
    }
}

