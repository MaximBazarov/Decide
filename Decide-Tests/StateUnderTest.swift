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

    static let defaultSUTName = "default-sut-name"

    @Property var name: String = defaultSUTName    
}

final class KeyedStateUnderTest: KeyedState<UUID> {

    static let defaultSUTName = "default-sut-name"

    @Property var name: String = defaultSUTName

}
