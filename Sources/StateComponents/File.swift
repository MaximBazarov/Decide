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

protocol AtomicState {
    associatedtype Value
    static func defaultValue() -> Value
}

extension Observe {
    convenience init<T: AtomicState>(_ type: T.Type) where T.Value == Value {
        let key = StorageKey.atom(ObjectIdentifier(type))
        self.init(
            key: key,
            onBehalf: key,
            defaultValue: type.defaultValue
        )
    }
}
