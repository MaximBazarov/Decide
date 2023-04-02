//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import Combine

/// ObservableObject for a value in ``StorageSystem``.
public final class ObservableValue: ObservableObject, Hashable {

    let context: Context

    public init(context: Context) {
        self.context = context
    }

    public func valueWillChange() {
        objectWillChange.send()
    }

    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    public static func == (lhs: ObservableValue, rhs: ObservableValue) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
