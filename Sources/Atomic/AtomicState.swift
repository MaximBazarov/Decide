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

import Foundation

/// Value that exist only once per ``StorageSystem``
public protocol AtomicState {
    /// Type of the state's value.
    associatedtype Value
    /// Default value for the state, used if read before write.
    static func defaultValue() -> Value
}

extension AtomicState {
    static var key: StorageKey {
        StorageKey(type: Self.self)
    }
}

