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

extension DefaultValues {

    /// ``Decide`` framework dependencies
    @MainActor struct DecideDependencies {
        var storage: StorageSystem { InMemoryStorage() }
        var core: DecisionEffectSystem { LocalDecisionEffectSystem() }
    }

    /// ``Decide`` framework dependencies
    var decide: DecideDependencies { .init() }
}
