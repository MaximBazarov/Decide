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

@MainActor final class SwiftUI_Tests: XCTestCase {

    final class Storage: StateRoot {
        init() {}

        @ObservableValue
        @Persistent
        var str = "str-default"

        func doTest() {
        }
    }

    struct UpdateStr: ValueDecision {
        var newValue: String

        func mutate(_ env: DecisionEnvironment) {
            var x = env[\Storage.$str]
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

