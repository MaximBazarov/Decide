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
/// Default environment is a way to have a shared  ``ApplicationEnvironment``
/// across the components that neither ``Decision``, ``Effect`` nor `SwiftUI` views
/// e.g. `UIViewController`, some legacy services etc.
///
/// Check ``EnvironmentObservingObject`` and ``EnvironmentManagedObject`` to learn
/// how to access ``ObservableState``s in legacy context.
///
/// Usage:
/// ```swift
/// // A reference to ``ApplicationEnvironment``.default
/// @DefaultEnvironment var environment
/// ```
@MainActor @propertyWrapper public final class DefaultEnvironment {
    public var wrappedValue: ApplicationEnvironment = .default
    public init() {}
}

/// An object managed by environment
/// - Instantiated and held by ``ApplicationEnvironment``.
/// - `environment` value is set to the ``ApplicationEnvironment`` it is executed in.
///
public protocol EnvironmentManagedObject: AnyObject {
    @MainActor var environment: ApplicationEnvironment { get set }
}

@MainActor public protocol EnvironmentObservingObject: AnyObject {
    @MainActor var environment: ApplicationEnvironment { get set }
    @MainActor func environmentDidUpdate()
}

