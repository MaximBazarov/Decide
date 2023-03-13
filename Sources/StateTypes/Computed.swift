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
// MARK: - Atomic State
//===----------------------------------------------------------------------===//

/// Value that is computed using ``StorageReader``.
public protocol ComputedState {
    /// Type of the state's value.
    associatedtype Value

    /// Default value for the state, used if read before write.
    static func compute(read: StorageReader) -> Value
}

//===----------------------------------------------------------------------===//
// MARK: - Writer
//===----------------------------------------------------------------------===//
extension ComputedState {
    static var key: StorageKey {
        StorageKey(type: Self.self, additionalKeys: [])
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

public extension StorageReader {
    func callAsFunction<T: ComputedState>(
        _ type: T.Type,
        context: Context
    ) -> T.Value {
        let post = Signposter()
        post.logger.trace("[Storage Reader] computation reader with owner: \(type.key.debugDescription) context: \(context.debugDescription)")
        return read(
            key: type.key,
            fallbackValue: {
                type.compute(read: self.withOwner(type.key))
            },
            shouldStoreDefaultValue: false,
            context: context
        )
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

@MainActor public extension Observe {
    /// Read-only access to the value of the ``ComputedState``
    init<T: ComputedState>(
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
            reader(type, context: context)
        })
    }
}
