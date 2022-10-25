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

import XCTest
import Decide

@MainActor final class WrappersIntegrationTests: XCTestCase {
    func test_Observe_EmptyStorage_mustReturn_DefaultValue() {
    }

    func test_Observe_WrittenValue_mustReturn_WrittenValue() {
    }

    /**
     Read:
     - read default value
     - write value through binding must produce a BindingDirectMutation
     - observe value must trigger an update:
        - Int
        - String
            - add character
            - remove character
            - swap characters
            - change char
            - += -= etc operators
            - remove substring
            - add substring
        - Dictionary
            - key removal
            - add key and value
            - change value for key
            - += -= etc operators
        - Array
            - add element
            - remove element
            - swap elements
            - element change
            - += -= etc operators
     - bind should mutate and send an update for:
         - Int
         - String
             - add character
             - remove character
             - swap characters
             - change char
             - += -= etc operators
             - remove substring
             - add substring
         - Dictionary
             - key removal
             - add key and value
             - change value for key
             - += -= etc operators
         - Array
             - add element
             - remove element
             - swap elements
             - element change
             - += -= etc operators
     */
}
