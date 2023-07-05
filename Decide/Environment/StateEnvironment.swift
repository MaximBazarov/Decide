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

@MainActor public final class StateEnvironment {
    enum Key: Hashable {
        case atomic(ObjectIdentifier)
        case keyed(ObjectIdentifier, AnyHashable)
    }

    static let `default` = StateEnvironment()

    var storage: [Key: Any] = [:]

    public init() {}
}
