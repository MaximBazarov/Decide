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

final class StateUnderTest: AtomicState {
    @Property var name: String = "default-sut-name"
}

final class KeyedStateUnderTest: KeyedState<UUID> {
    @Property var name: String = "default-sut-name"
}
