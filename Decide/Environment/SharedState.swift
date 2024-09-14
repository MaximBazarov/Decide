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

/// Provides identity for ``ObservableValue`` as a root for the value `KeyPath`.
/// All ``ObservableValue`` and ``ObservableIdentifiedValue`` must be declared within the ``SharedState``.
/// This allows the value to be referenced in access property wrappers like ``ObserveState`` e.g. `\MyState.myValue`.
///
/// **Example:**
/// ```swift
/// @MainActor final class MainCounter {
///     @ObservableValue var count = 0
/// }
///
/// @MainActor final class AnotherCounter {
///     @ObservableValue var count = 0
/// }
/// ```
///
/// This describes the observable values that can be referenced as `\MainCounter.$count` and `\AnotherCounter.$count`.
@MainActor public protocol SharedState: AnyObject {
    init()
}
