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

    final class Storage: KeyedStorage<Int> {
        @ObservableState var str = "str-default"
        @Mutable @ObservableState var strMutable = "strMutable-default"
    }

    struct ViewUnderTest: View {
        @BindKeyed(\Storage.$strMutable) var strMutable
        @ObserveKeyed(\Storage.$str) var str
        @ObserveKeyed(\Storage.$strMutable) var strMutableObserved

        var body: some View {
            TextField("", text: strMutable[1])
            Text(str[1])
            Text(strMutableObserved[1])
        }
    }

}

