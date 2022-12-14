//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import Inject

public extension DefaultValues {

    /// Application state and side effects ``DecisionExecutor``
    var decisionCore: DecisionExecutor {
        DecisionCore(
            storage: InMemoryStorage(),
            dependencies: DependencyGraph(),
            observation: ObservationSystem()
        )
    }
}
