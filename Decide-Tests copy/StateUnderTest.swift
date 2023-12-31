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

import Decide
import Foundation

final class StateUnderTest: AtomicStorage {
    static let defaultName = "default-atomic-state-name"
    @Mutable @ObservableState var name = defaultName
}

final class KeyedStateUnderTest: KeyedStorage<UUID> {
    static let defaultName = "default-keyed-state-name"
    @Mutable @ObservableState var name = defaultName
}

