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

let intDefaultValue: Int = 0xDEF017

final class IntStateSample: AtomicState {
    static func defaultValue() -> Int { intDefaultValue }
}

final class ReadIntStateSample: Decision {
    func execute(read: StorageReader, write: StorageWriter) -> Effect {
        let _ = read(IntStateSample.self)
        return NoOperation()
    }
}
