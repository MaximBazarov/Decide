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

/// Describes a "region" of in the environment to store ``ObservableState``.
/// Serves as a root type for the ``ObservableState`` keys,
/// e.g. `\MyState.myValue`. Here `MyState` is a ``StateRoot``.
@MainActor public protocol StateRoot: AnyObject {
    init()
}
