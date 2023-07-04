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
    public static let defaultValue: StateEnvironment = .default
}

public extension EnvironmentValues {
    var stateEnvironment: StateEnvironment {
        get { self[StateEnvironmentKey.self] }
        set { self[StateEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func stateManagement(_ value: StateEnvironment) -> some View {
        environment(\.stateEnvironment, value)
    }
}


