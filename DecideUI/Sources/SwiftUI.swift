// SwiftUI.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

import Decide
import SwiftUI

private struct SharedEnvironment_SwiftUIEnvironmentKey: EnvironmentKey {
    static let defaultValue: SharedEnvironment = .default
}

public extension EnvironmentValues {
    var sharedEnvironment: SharedEnvironment {
        get { self[SharedEnvironment_SwiftUIEnvironmentKey.self] }
        set { self[SharedEnvironment_SwiftUIEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Overrides ``SharedEnvironment`` in the SwiftUI view `Environment`.
    func sharedEnvironment(_ value: SharedEnvironment) -> some View {
        environment(\.sharedEnvironment, value)
    }
}
