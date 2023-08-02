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

/// Modifier applied to property to change it bechaviour e.g ``Mutable`` alows property to be directly mutated through bindings e.g. ``Bind``.
@MainActor public protocol PropertyModifier {
    associatedtype Value
    var wrappedValue: Property<Value> { get }
}
