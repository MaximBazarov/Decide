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



/// KeyPath to the value container ``Property`` or ``Computed``
enum ValueContainerKeyPath<State, Value, I: Hashable> {
    case property(KeyPath<State, Property<Value>>)
    case computed(KeyPath<State, Computed<Value>>)
    case computedKeyed(KeyPath<State, ComputedKeyed<I, Value>>)
}
