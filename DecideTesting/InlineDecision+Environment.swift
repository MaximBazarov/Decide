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

import Decide

public extension ApplicationEnvironment {

    private struct DecideTestingMutation: Decision {
        func mutate(_ env: Decide.DecisionEnvironment) {
            mutation(env)
        }
        
        var mutation: EnvironmentMutation
    }

    func makeDecision(_ mutation: @escaping EnvironmentMutation, file: StaticString = #file, line: UInt = #line) {
        let decision = DecideTestingMutation(mutation: mutation)
        self.make(decision: decision, context: Context(file: file, line: line))
    }
}
