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

    final class State: KeyedState<Int> {
        @Property var str = "str-default"
        @Mutable @Property var strMutable = "strMutable-default"
    }

    struct ViewUnderTest: View {
        @BindKeyed(\State.$strMutable) var strMutable

        var body: some View {
            TextField("", text: strMutable[1])
        }
    }

}

