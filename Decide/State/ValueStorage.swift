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

@MainActor
public final class ValueStorage<Value> {
    public var initialValue: () -> Value
    public var value: Value {
        get {
            if let value = _value {
                return value
            }

            let newValue = initialValue()
            _value = newValue
            return newValue
        }
        set {
            _value = newValue
        }
    }

    var _value: Value?
    init(
        initialValue: @escaping () -> Value
    ) {
        self.initialValue = initialValue
    }
}
