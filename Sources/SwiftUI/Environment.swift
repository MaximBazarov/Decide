//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import SwiftUI

struct CoreEnvironmentKey: EnvironmentKey {
    @MainActor
    static var defaultValue: Storage = DecisionEffectStorage()
}

public extension EnvironmentValues {

    /// A View modifier that provides a convenient way to set and access a ``Storage`` instance in the environment.
    ///
    /// Use the `\.decisionCore` Key Path to access the ``Storage`` instance in the environment.
    ///
    /// **Example:**
    /// ```
    /// struct ContentView: View {
    ///     @Environment(\.decisionCore) var decisionCore
    ///     ...
    /// }
    /// ```
    ///
    /// **Usage:**
    /// ```
    /// struct ContentView: View {
    ///     var body: some View {
    ///         MyView()
    ///             .decisionCore(injectedCore)
    ///     }
    /// }
    /// ```
    var decisionCore: Storage {
        get { self[CoreEnvironmentKey.self] }
        set { self[CoreEnvironmentKey.self] = newValue }
    }
}

/// An extension that provides a convenient way to set a `Storage` instance in the environment for a specific view.
///
/// Use the `decisionCore(_:)` modifier to set the `Storage` instance in the environment for a specific view.
///
/// Example:
/// ```
/// struct MyView: View {
///     @MakeDecision var makeDecision: (Decision) -> Void
///
///     var body: some View {
///         Button("Accept") {
///             makeDecision(.accept)
///         }
///         Button("Reject") {
///             makeDecision(.reject)
///         }
///     }
/// }
///
/// MyView()
///     .decisionCore(MyCustomDecisionCore())
/// ```
public extension View {

    /// Sets the `Storage` instance in the environment for this view.
    /// - Parameter core: The `Storage` instance to set in the environment.
    /// - Returns: A new view that sets the `Storage` instance in the environment.
    func decisionCore(_ core: Storage) -> some View {
        environment(\.decisionCore, core)
    }
}
