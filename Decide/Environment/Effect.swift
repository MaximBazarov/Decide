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

/// Serves as the abstraction for side effects.
/// Use ``EnvironmentValue`` and ``EnvironmentInstance``
/// to access values and instances within the environment.
///
/// **Usage**
/// ```swift
/// 
/// ```
public class Effect: EnvironmentManagedObject {
    public var environment: StateEnvironment = .default
    open func perform() async {}
}
