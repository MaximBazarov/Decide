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

public extension StorageWriter {
    func callAsFunction<T: AtomicState>(_ value: T.Value, into type: T.Type) {
        let key = StorageKey.atom(ObjectIdentifier(type))
        write(value, for: key, onBehalf: key)
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

public extension StorageReader {
    func callAsFunction<T: AtomicState>(_ type: T.Type) -> T.Value {
        let key = StorageKey.atom(ObjectIdentifier(type))
        return read(key: key, onBehalf: key, defaultValue: type.defaultValue)
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

@MainActor public extension Observe {
    /// Read-only access to the value of the ``AtomicState``
    convenience init<T: AtomicState>(_ type: T.Type) where T.Value == Value {
        self.init(getValue: { reader in
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

