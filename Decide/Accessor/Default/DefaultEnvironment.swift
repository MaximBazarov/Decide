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

@MainActor public protocol EnvironmentObservingObject: AnyObject {
    @MainActor var environment: ApplicationEnvironment { get set }
    @MainActor func environmentDidUpdate()
}

/// Property wrapper to access default environment,
/// to be used on ``EnvironmentManagedObject`` and ``EnvironmentObservingObject``.
///
/// Usage:
/// ```swift
/// @DefaultEnvironment var environment
/// ```
@MainActor @propertyWrapper public final class DefaultEnvironment {
    public var wrappedValue: ApplicationEnvironment = .default
    public init() {}
}
