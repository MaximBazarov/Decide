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

import Foundation

@MainActor public protocol Computation {
    associatedtype Value
    static func compute(read: StorageReader) -> Value
}

extension Computation {
    static var key: StorageKey {
        StorageKey(type: Self.self, additionalKeys: [])
    }
}

public extension StorageReader {
    func callAsFunction<T: Computation>(_ type: T.Type) -> T.Value {
        return read(
            key: type.key,
            fallbackValue: {  type.compute(read: self.withOwner(type.key)) },
            shouldStoreDefaultValue: true
        )
    }
}

@MainActor public extension Observe {
    /// Read-only access to the value of the ``AtomicState``
    init<T: Computation>(_ type: T.Type) where T.Value == Value {
        self.init(key: T.key, getValue: { reader in
            reader(type)
        })
    }
}
