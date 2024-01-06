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

/**
 Provides a function to make decisions.

 ```swift
 @EnvironmenObject
 final class SomeClass {
    @MakeDecision var decideTo

    func someWork(x: Int) {
        decideTo(
            UpdateSomeThing(someValue: x)
        )
    }
 }
 ```
 */
@propertyWrapper
@MainActor
final class MakeDecision {
    unowned var environment: SharedEnvironment
    init() {
        self.environment = SharedEnvironment.default
    }

    lazy var decisionEnvironment: DecisionEnvironment = DecisionEnvironment(environment)

    lazy var wrappedValue: (Decision) -> Void = { decision in
        self.decisionEnvironment.make(decision: decision)
    }
}


#if canImport(SwiftUI)
import SwiftUI

@propertyWrapper
@MainActor
final class MakeDecisionSwiftUI {
    @SwiftUI.Environment(\.sharedEnvironment) var environment

    init() {}

    lazy var decisionEnvironment: DecisionEnvironment = DecisionEnvironment(environment)

    lazy var wrappedValue: (Decision) -> Void = { decision in
        self.decisionEnvironment.make(decision: decision)
    }
}
#endif
