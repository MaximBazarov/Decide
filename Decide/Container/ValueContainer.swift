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

/// Single source of truth for values in ``ApplicationEnvironment``.
@MainActor public final class ValueContainer<Value> {
    var value: Value?
    private(set) var observerStorage = ObserverStorage()
    private(set) var persistencyStrategy: PersistencyStrategy<Value>?

    init() {}
}
