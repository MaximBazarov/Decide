//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
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


     //===----------------------------------------------------------------------===//
     // MARK: - Storage Injection Tests
     //===----------------------------------------------------------------------===//

     func test_Observe_Storage_Override_mustHave_LocalStorage() {
     @Observe(IntStateSample.self) var sut;
     @Observe(IntStateSample.self) var global;

     let storage = InMemoryStorage()
     _sut.storage.override(with: storage)

     let writeGlobal = StorageWriter(storage: _global.storage.instance)
     let writeLocal = StorageWriter(storage: storage)

     let key = IntStateSample.key

     writeGlobal.write(12, for: key, onBehalf: key)
     writeLocal.write(10, for: key, onBehalf: key)

     XCTAssertEqual(10, sut)
     }
     */
}
