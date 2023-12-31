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
import OSLog

let osLogDecideSubsystem = "Decide"

/// Shared environment among all components of the system.
/// Unless overridden in component, ``SharedEnvironment/default`` is used.
public final class SharedEnvironment {
    typealias Key = ObjectIdentifier
    @MainActor private var warehouse: [Key: any StateRoot] = [:]

    /// Provides the storage of a given type
    /// that conforms to ``EnvironmentStateStorage``
    @MainActor func get<Root: StateRoot>(_ type: Root.Type) -> Root {
        let key = Key(type)
        if let value = warehouse[key] {
            return unsafeDowncast(value, to: Root.self)
        }

        let value = type.init(environment: self)
        warehouse[key] = value
        return value
    }
}

//===----------------------------------------------------------------------===//
// MARK: - SwiftUI Support
//===----------------------------------------------------------------------===//

#if canImport(SwiftUI)
import SwiftUI

private struct SharedEnvironment_SwiftUIEnvironmentKey: EnvironmentKey {
    static let defaultValue: SharedEnvironment = .default
}

public extension EnvironmentValues {

    /// Overrides ``Environment`` in the SwiftUI View environment
    var sharedEnvironment: SharedEnvironment {
        get { self[SharedEnvironment_SwiftUIEnvironmentKey.self] }
        set { self[SharedEnvironment_SwiftUIEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Overrides ``Environment`` in the view environment`
    func sharedEnvironment(_ value: SharedEnvironment) -> some View {
        environment(\.sharedEnvironment, value)
    }
}
#endif
