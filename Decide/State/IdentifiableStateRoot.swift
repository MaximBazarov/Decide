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

/// Describes an identifiable by ``Identifier`` "region"
/// of in the environment to store ``ObservableValue``.
/// Serves as a root type for the ``ObservableValue`` keys,
/// e.g. `\MyState.myValue, at: id`.
/// Here `MyState` is an ``IdentifiedStateRoot``.
/// And `id` is of type ``Identifier``.
@MainActor public protocol IdentifiedStateRoot: AnyObject {
    associatedtype Identifier
    var id: Identifier { get }
    init(id: Identifier)
}
