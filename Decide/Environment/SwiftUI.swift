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

@MainActor private struct ApplicationEnvironmentKey: EnvironmentKey {
    /// Default ``ApplicationEnvironment`` value
    public static let defaultValue: ApplicationEnvironment = .default
}

public extension EnvironmentValues {
    
    /// Overrides ``ApplicationEnvironment`` in the view environment`
    var stateEnvironment: ApplicationEnvironment {
        get { self[ApplicationEnvironmentKey.self] }
        set { self[ApplicationEnvironmentKey.self] = newValue }
    }
}

public extension View {
    
    /// Overrides ``ApplicationEnvironment`` in the view environment`
    func appEnvironment(_ value: ApplicationEnvironment) -> some View {
        environment(\.stateEnvironment, value)
    }
}


