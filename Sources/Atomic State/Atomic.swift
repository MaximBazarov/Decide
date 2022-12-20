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
    func callAsFunction<T: AtomicState>(_ value: T.Value, into type: T.Type, context: Context = .here()) {
        write(value, for: type.key, onBehalf: type.key, context: context)
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

public extension StorageReader {
    func callAsFunction<T: AtomicState>(_ type: T.Type, context: Context = .here()) -> T.Value {
        return read(
            key: type.key,
            fallbackValue: type.defaultValue,
            shouldStoreDefaultValue: true,
            context: context
        )
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

@MainActor public extension Observe {
    /// Read-only access to the value of the ``AtomicState``
    init<T: AtomicState>(
        _ type: T.Type,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) where T.Value == Value {
        let context: Context = Context(
            className: function,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
        self.init(key: T.key, getValue: { reader in
            reader.callAsFunction(type, context: context)
        })
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Bind
//===----------------------------------------------------------------------===//

@MainActor public extension Bind {
    /// Read/write access to the value of the ``AtomicState``
    init<T: AtomicState>(
        _ state: T.Type,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) where T.Value == Value {
        let context: Context = Context(
            className: function,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
        self.init(
            key: state.key,
            getValue: { read in read(state, context: context) },
            setValue: { write, value in write(value, into: state, context: context) }
        )
    }
}

