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

import SwiftUI

@MainActor private struct StateEnvironmentKey: EnvironmentKey {
    /// Default ``StateEnvironment`` value
    public static let defaultValue: StateEnvironment = .default
}

public extension EnvironmentValues {
    
    /// Overrides ``StateEnvironment`` in the view environment`
    var stateEnvironment: StateEnvironment {
        get { self[StateEnvironmentKey.self] }
        set { self[StateEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Overrides ``StateEnvironment`` in the view environment`
    func stateEnvironment(_ value: StateEnvironment) -> some View {
        environment(\.stateEnvironment, value)
    }
}


