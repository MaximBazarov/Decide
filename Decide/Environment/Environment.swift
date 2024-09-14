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

public extension SharedEnvironment {
    static let `default` = SharedEnvironment()
}

/// Shared environment among all components of the system.
/// Unless overridden in component, ``SharedEnvironment/default`` is used.
public final class SharedEnvironment {
    typealias Key = ObjectIdentifier

    @MainActor private(set) var warehouse: [Key: AnyObject] = [:]

    /// Provides the storage of a given type
    /// that conforms to ``EnvironmentStateStorage``
    @MainActor func get<State: SharedState>(_ type: State.Type) -> State {
        let key = ObjectIdentifier(type)
        if let sharedState = warehouse[key] {
            return unsafeDowncast(sharedState, to: State.self)
        }

        let newSharedState = type.init()
        warehouse[key] = newSharedState
        return newSharedState
    }
}
