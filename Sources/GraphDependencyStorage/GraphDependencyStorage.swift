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

@MainActor final class DependenciesAutoGraphStorage: Storage {
    func getValue<V>(for key: StorageKey, onBehalf ownerKey: StorageKey?, defaultValue: () -> V) -> V {
        fatalError()
    }

    func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?) {
        fatalError()
    }
}
