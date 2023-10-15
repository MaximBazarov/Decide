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
import Decide

public extension ApplicationEnvironment {

    private struct TestingDecision: Decision {
        func mutate(_ env: Decide.DecisionEnvironment) {
            mutation(env)
        }
        
        let mutation: EnvironmentMutation
    }

    func decision(_ mutate: @escaping EnvironmentMutation, file: StaticString = #file, line: UInt = #line) {
        self.make(decision: TestingDecision(mutation: mutate), context: Context(file: file, line: line))
    }
}
