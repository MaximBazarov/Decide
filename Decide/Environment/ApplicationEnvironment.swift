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

/// ApplicationEnvironment stores instances of ``AtomicState`` and ``KeyedState`` and provides tools for mutations and asyncronous executions of side-effects.
@MainActor public final class ApplicationEnvironment {
    enum Key: Hashable {
        case atomic(ObjectIdentifier)
        case keyed(ObjectIdentifier, AnyHashable)
    }

    static let `default` = ApplicationEnvironment()

    var storage: [Key: Any] = [:]

    public init() {}
}
