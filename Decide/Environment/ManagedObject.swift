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


/// An object managed by environment
/// - Instantiated and held by ``StateEnvironment``.
/// - `environment` value is set to the ``StateEnvironment`` it is executed in.
/// 
public protocol EnvironmentManagedObject {
    var environment: StateEnvironment { get set }
}
