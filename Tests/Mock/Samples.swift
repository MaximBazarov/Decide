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

import Decide

//===----------------------------------------------------------------------===//
// MARK: - Int
//===----------------------------------------------------------------------===//

let intDefaultValue: Int = 0xDEFA17

final class IntStateSample: AtomicState {
    static func defaultValue() -> Int { intDefaultValue }
}

//===----------------------------------------------------------------------===//
// MARK: - String
//===----------------------------------------------------------------------===//

let stringDefaultValue: String = "DEFAULT"
final class StringStateSample: AtomicState {
    static func defaultValue() -> String { stringDefaultValue }
}
