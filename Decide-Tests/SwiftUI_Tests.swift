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
import Decide
import XCTest
import DecideTesting

@MainActor final class SwiftUI_Tests: XCTestCase {

    final class Storage: StateRoot {
        unowned var environment: Decide.SharedEnvironment
        init(environment: Decide.SharedEnvironment) {
            self.environment = environment
        }

        @ObservableValue
        @Persistent
        var str = "str-default"

        func doTest() {
        }
    }

    struct UpdateStr: ValueDecision {
        var newValue: String

        func mutate(_ env: Decide.DecisionEnvironment) {
//            env[\.Storage.$str] = newValue
        }
    }

    struct ViewUnderTest: View {
        @SwiftUIBind(
            \Storage.$str,
             mutate: UpdateStr.self
        ) var str

        var body: some View {
            EmptyView()
//            TextField("", text: $str)
//            Text(str[1])
//            Text(strMutableObserved[1])
        }
    }

}

